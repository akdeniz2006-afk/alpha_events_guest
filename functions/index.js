const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { logger } = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

function chunkArray(items, size) {
  const chunks = [];

  for (let i = 0; i < items.length; i += size) {
    chunks.push(items.slice(i, i + size));
  }

  return chunks;
}

exports.sendEventNotificationPush = onDocumentCreated(
  {
    document: "event_notifications/{notificationId}",
    region: "europe-west1",
    timeoutSeconds: 120,
    memory: "512MiB",
  },
  async (event) => {
    const snap = event.data;

    if (!snap) {
      logger.warn("Notification snapshot is empty.");
      return;
    }

    const notificationId = event.params.notificationId;
    const data = snap.data() || {};

    const title = (data.title || "Alpha Events").toString().trim();
    const body = (data.body || data.message || "").toString().trim();
    const eventId = (data.eventId || "zurich_2026").toString().trim();
    const sendNow = data.sendNow !== false;
    const status = (data.status || "pending").toString();

    if (!sendNow) {
      logger.info("Notification is not marked for immediate sending.", {
        notificationId,
      });
      return;
    }

    if (status === "sent") {
      logger.info("Notification already sent.", {
        notificationId,
      });
      return;
    }

    if (!title || !body) {
      await snap.ref.set(
        {
          status: "error",
          error: "title/body empty",
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      logger.warn("Notification title/body empty.", {
        notificationId,
      });

      return;
    }

    const tokenSnapshot = await admin
      .firestore()
      .collection("event_push_tokens")
      .where("eventId", "==", eventId)
      .where("isActive", "==", true)
      .get();

    const tokenDocs = tokenSnapshot.docs;
    const tokens = tokenDocs
      .map((doc) => (doc.data().token || "").toString().trim())
      .filter((token) => token.length > 0);

    if (tokens.length === 0) {
      await snap.ref.set(
        {
          status: "error",
          error: "no active push tokens",
          tokenCount: 0,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      logger.warn("No active tokens found.", {
        notificationId,
        eventId,
      });

      return;
    }

    await snap.ref.set(
      {
        status: "sending",
        tokenCount: tokens.length,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    const tokenChunks = chunkArray(tokens, 500);

    let successCount = 0;
    let failureCount = 0;
    const invalidTokens = [];

    for (const tokenChunk of tokenChunks) {
      const response = await admin.messaging().sendEachForMulticast({
        tokens: tokenChunk,
        notification: {
          title,
          body,
        },
        webpush: {
          notification: {
            title,
            body,
            icon: "/icons/Icon-192.png",
            badge: "/icons/Icon-192.png",
          },
          fcmOptions: {
            link: "https://alpha-events-app.web.app",
          },
        },
        data: {
          notificationId,
          eventId,
          type: (data.type || "general").toString(),
        },
      });

      successCount += response.successCount;
      failureCount += response.failureCount;

      response.responses.forEach((result, index) => {
        if (!result.success) {
          const failedToken = tokenChunk[index];
          const code = result.error ? result.error.code : "";

          if (
            code === "messaging/registration-token-not-registered" ||
            code === "messaging/invalid-registration-token"
          ) {
            invalidTokens.push(failedToken);
          }

          logger.warn("Push token failed.", {
            notificationId,
            code,
          });
        }
      });
    }

    const batch = admin.firestore().batch();

    invalidTokens.forEach((token) => {
      const ref = admin.firestore().collection("event_push_tokens").doc(token);
      batch.set(
        ref,
        {
          isActive: false,
          disabledAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    });

    if (invalidTokens.length > 0) {
      await batch.commit();
    }

    await snap.ref.set(
      {
        status: "sent",
        successCount,
        failureCount,
        invalidTokenCount: invalidTokens.length,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    logger.info("Push notification sent.", {
      notificationId,
      eventId,
      tokenCount: tokens.length,
      successCount,
      failureCount,
    });
  }
);