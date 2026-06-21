const {onRequest} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

const db = admin.firestore();

const EVENT_ID = "zurich_2026";
const VERIFY_TOKEN = process.env.WHATSAPP_VERIFY_TOKEN || "alpha_events_verify_2026";
const WHATSAPP_TOKEN = process.env.WHATSAPP_TOKEN || "";
const WHATSAPP_PHONE_NUMBER_ID = process.env.WHATSAPP_PHONE_NUMBER_ID || "";

function normalizeText(value) {
  return (value || "")
    .toString()
    .toLowerCase()
    .replaceAll("ı", "i")
    .replaceAll("ğ", "g")
    .replaceAll("ü", "u")
    .replaceAll("ş", "s")
    .replaceAll("ö", "o")
    .replaceAll("ç", "c")
    .trim();
}

function normalizePhone(value) {
  return (value || "").toString().replace(/\D/g, "");
}

function phoneMatches(sourcePhone, whatsappPhone) {
  const source = normalizePhone(sourcePhone);
  const incoming = normalizePhone(whatsappPhone);

  if (!source || !incoming) return false;

  return (
    source === incoming ||
    source.endsWith(incoming) ||
    incoming.endsWith(source) ||
    source.endsWith(incoming.slice(-10)) ||
    incoming.endsWith(source.slice(-10))
  );
}

function getTextMessage(body) {
  try {
    const value = body.entry?.[0]?.changes?.[0]?.value;
    const message = value?.messages?.[0];

    if (!message) return null;

    return {
      from: message.from || "",
      text: message.text?.body || "",
      type: message.type || "",
      messageId: message.id || "",
    };
  } catch (error) {
    console.error("getTextMessage error", error);
    return null;
  }
}

async function findGuestByPhone(phone) {
  const snapshot = await db
    .collection("event_guests")
    .where("eventId", "==", EVENT_ID)
    .get();

  for (const doc of snapshot.docs) {
    const data = doc.data();

    const phones = [
      data.phone,
      data.phoneNumber,
      data.whatsapp,
      data.whatsappNumber,
      data.mobile,
      data.gsm,
    ];

    if (phones.some((item) => phoneMatches(item, phone))) {
      return {
        id: doc.id,
        ...data,
      };
    }
  }

  return null;
}

async function findGuestByCode(code) {
  const cleanCode = normalizeText(code);

  if (!cleanCode) return null;

  const snapshot = await db
    .collection("event_guests")
    .where("eventId", "==", EVENT_ID)
    .get();

  for (const doc of snapshot.docs) {
    const data = doc.data();

    const guestCode = normalizeText(data.code || data.guestCode || "");
    const guestId = normalizeText(data.guestId || "");

    if (guestCode === cleanCode || guestId === cleanCode) {
      return {
        id: doc.id,
        ...data,
      };
    }
  }

  return null;
}

function detectIntent(text) {
  const q = normalizeText(text);

  if (
    q.includes("oda") ||
    q.includes("room") ||
    q.includes("kaldigim") ||
    q.includes("kalacağım") ||
    q.includes("kalacagim")
  ) {
    return "room_info";
  }

  if (
    q.includes("otel") ||
    q.includes("hotel") ||
    q.includes("konaklama")
  ) {
    return "hotel_info";
  }

  if (
    q.includes("transfer") ||
    q.includes("servis") ||
    q.includes("shuttle") ||
    q.includes("otobus") ||
    q.includes("otobüs") ||
    q.includes("arac") ||
    q.includes("araç")
  ) {
    return "transfer_info";
  }

  if (
    q.includes("program") ||
    q.includes("toplanti") ||
    q.includes("toplantı") ||
    q.includes("saat") ||
    q.includes("agenda") ||
    q.includes("meeting")
  ) {
    return "program_info";
  }

  if (
    q.includes("duyuru") ||
    q.includes("announcement") ||
    q.includes("bilgilendirme")
  ) {
    return "announcement_info";
  }

  if (
    q.includes("aktivite") ||
    q.includes("activity") ||
    q.includes("gala") ||
    q.includes("yemek")
  ) {
    return "activity_info";
  }

  if (
    q.includes("acil") ||
    q.includes("yardim") ||
    q.includes("yardım") ||
    q.includes("emergency") ||
    q.includes("destek")
  ) {
    return "emergency_info";
  }

  return "unknown";
}

function guestName(guest) {
  return guest.guestName || guest.name || "Değerli katılımcımız";
}

function guestRoom(guest) {
  return (
    guest.room ||
    guest.roomNumber ||
    guest.roomNo ||
    guest.roomName ||
    ""
  ).toString().trim();
}

function guestHotel(guest) {
  return (
    guest.hotel ||
    guest.hotelName ||
    guest.accommodationHotel ||
    ""
  ).toString().trim();
}

function guestTransfer(guest) {
  return (
    guest.transport ||
    guest.transportGroup ||
    guest.transfer ||
    guest.transferGroup ||
    ""
  ).toString().trim();
}

async function getProgramAnswer() {
  const snapshot = await db
    .collection("event_program")
    .where("eventId", "==", EVENT_ID)
    .get();

  if (snapshot.empty) {
    return "Program bilgisi henüz sistemde görünmüyor. Lütfen operasyon ekibiyle iletişime geçin.";
  }

  const items = snapshot.docs
    .map((doc) => doc.data())
    .sort((a, b) => {
      const aText = `${a.dayDate || ""} ${a.time || ""}`;
      const bText = `${b.dayDate || ""} ${b.time || ""}`;
      return aText.localeCompare(bText);
    })
    .slice(0, 5);

  const lines = items.map((item) => {
    const day = item.dayTitle || item.dayDate || "";
    const time = item.time || "";
    const title = item.title || "Program";
    const location = item.location ? ` - ${item.location}` : "";
    return `• ${day} ${time} ${title}${location}`.trim();
  });

  return `Programdan öne çıkan bilgiler:\n${lines.join("\n")}`;
}

async function getAnnouncementAnswer() {
  const snapshot = await db
    .collection("event_announcements")
    .where("eventId", "==", EVENT_ID)
    .get();

  if (snapshot.empty) {
    return "Şu anda sistemde aktif duyuru görünmüyor.";
  }

  const items = snapshot.docs
    .map((doc) => doc.data())
    .slice(0, 3);

  const lines = items.map((item) => {
    const title = item.title || "Duyuru";
    const description = item.description || "";
    return `• ${title}${description ? ": " + description : ""}`;
  });

  return `Güncel duyurular:\n${lines.join("\n")}`;
}

async function getActivityAnswer() {
  const snapshot = await db
    .collection("event_activities")
    .where("eventId", "==", EVENT_ID)
    .get();

  if (snapshot.empty) {
    return "Şu anda sistemde aktivite bilgisi görünmüyor.";
  }

  const items = snapshot.docs
    .map((doc) => doc.data())
    .slice(0, 5);

  const lines = items.map((item) => {
    const date = item.date || "";
    const time = item.time || "";
    const title = item.title || "Aktivite";
    const location = item.location ? ` - ${item.location}` : "";
    return `• ${date} ${time} ${title}${location}`.trim();
  });

  return `Aktivite bilgileri:\n${lines.join("\n")}`;
}

async function buildAnswer(guest, text) {
  const intent = detectIntent(text);
  const name = guestName(guest);

  if (intent === "room_info") {
    const room = guestRoom(guest);
    const hotel = guestHotel(guest);

    if (!room && !hotel) {
      return `${name}, oda ve otel bilginiz şu anda sistemde görünmüyor. Lütfen operasyon ekibiyle iletişime geçin.`;
    }

    return `${name}, oda bilginiz:\nOda: ${room || "Henüz atanmadı"}\nOtel: ${hotel || "Sistemde görünmüyor"}`;
  }

  if (intent === "hotel_info") {
    const hotel = guestHotel(guest);

    if (!hotel) {
      return `${name}, otel bilginiz şu anda sistemde görünmüyor. Lütfen operasyon ekibiyle iletişime geçin.`;
    }

    return `${name}, otel bilginiz: ${hotel}`;
  }

  if (intent === "transfer_info") {
    const transfer = guestTransfer(guest);
    const arrival = guest.arrival || guest.arrivalInfo || "";

    if (!transfer && !arrival) {
      return `${name}, transfer bilginiz şu anda sistemde görünmüyor. Lütfen operasyon ekibiyle iletişime geçin.`;
    }

    return `${name}, transfer bilginiz:\nTransfer: ${transfer || "Sistemde görünmüyor"}${arrival ? "\nVarış: " + arrival : ""}`;
  }

  if (intent === "program_info") {
    return await getProgramAnswer();
  }

  if (intent === "announcement_info") {
    return await getAnnouncementAnswer();
  }

  if (intent === "activity_info") {
    return await getActivityAnswer();
  }

  if (intent === "emergency_info") {
    return "Acil bir durumda lütfen operasyon ekibiyle iletişime geçin. Bu asistan kişisel telefon ve e-posta bilgilerini paylaşmaz.";
  }

  return `${name}, size oda, otel, transfer, program, duyuru ve aktivite bilgileri konusunda yardımcı olabilirim. Örneğin “Odam kaç?”, “Transferim var mı?”, “Program saat kaçta?” diye sorabilirsiniz.`;
}

async function sendWhatsappMessage(to, text) {
  if (!WHATSAPP_TOKEN || !WHATSAPP_PHONE_NUMBER_ID) {
    console.log("WhatsApp token veya phone number id yok. Cevap gönderilmedi:", {
      to,
      text,
    });
    return;
  }

  const url = `https://graph.facebook.com/v20.0/${WHATSAPP_PHONE_NUMBER_ID}/messages`;

  await axios.post(
    url,
    {
      messaging_product: "whatsapp",
      to,
      type: "text",
      text: {
        preview_url: false,
        body: text,
      },
    },
    {
      headers: {
        Authorization: `Bearer ${WHATSAPP_TOKEN}`,
        "Content-Type": "application/json",
      },
    },
  );
}

exports.whatsappWebhook = onRequest(
  {
    region: "europe-west1",
    cors: true,
  },
  async (req, res) => {
    try {
      if (req.method === "GET") {
        const mode = req.query["hub.mode"];
        const token = req.query["hub.verify_token"];
        const challenge = req.query["hub.challenge"];

        if (mode === "subscribe" && token === VERIFY_TOKEN) {
          console.log("WhatsApp webhook verified");
          return res.status(200).send(challenge);
        }

        return res.status(403).send("Verification failed");
      }

      if (req.method !== "POST") {
        return res.status(405).send("Method not allowed");
      }

      const message = getTextMessage(req.body);

      if (!message) {
        return res.status(200).send("No message");
      }

      if (message.type !== "text") {
        await sendWhatsappMessage(
          message.from,
          "Şu anda sadece yazılı mesajları yanıtlayabiliyorum.",
        );
        return res.status(200).send("Unsupported message type");
      }

      let guest = await findGuestByPhone(message.from);

      if (!guest) {
        guest = await findGuestByCode(message.text);
      }

      if (!guest) {
        await sendWhatsappMessage(
          message.from,
          "Kaydınızı telefon numaranızla doğrulayamadım. Lütfen katılımcı kodunuzu yazın.",
        );
        return res.status(200).send("Guest not found");
      }

      const answer = await buildAnswer(guest, message.text);

      await sendWhatsappMessage(message.from, answer);

      await db.collection("whatsapp_message_logs").add({
        eventId: EVENT_ID,
        from: message.from,
        messageId: message.messageId,
        text: message.text,
        answer,
        guestId: guest.guestId || guest.id || "",
        guestName: guest.guestName || guest.name || "",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return res.status(200).send("OK");
    } catch (error) {
      console.error("whatsappWebhook error", error);
      return res.status(500).send("Internal error");
    }
  },
);