importScripts("https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyCiCNt0uFyBTcCkqazPGrKbKbuxs79e8lF",
  authDomain: "alpha-events-app.firebaseapp.com",
  projectId: "alpha-events-app",
  storageBucket: "alpha-events-app.firebasestorage.app",
  messagingSenderId: "762110969571",
  appId: "1:762110969571:web:a5c2a1378de37f19c1a7d6"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  const title = payload.notification?.title || "Alpha Events";
  const options = {
    body: payload.notification?.body || "",
    icon: "/icons/Icon-192.png",
    badge: "/icons/Icon-192.png"
  };

  self.registration.showNotification(title, options);
});