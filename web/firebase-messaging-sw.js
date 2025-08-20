// Importa Firebase compatível com Service Worker
importScripts('https://www.gstatic.com/firebasejs/9.6.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.6.1/firebase-messaging-compat.js');

// Inicializa Firebase
firebase.initializeApp({
  apiKey: "AIzaSyDi9fsLQSnFn59793ChF3TKIIL3jzvTmNI",
  authDomain: "vitalog-ac0ba.firebaseapp.com",
  projectId: "vitalog-ac0ba",
  storageBucket: "vitalog-ac0ba.firebasestorage.app",
  messagingSenderId: "939108005872",
  appId: "1:939108005872:web:40f2e19899c1915c010f35",
  measurementId: "G-CHG3VQH33Q"
});

const messaging = firebase.messaging();

// Exibe notificação quando recebe mensagem em background
messaging.onBackgroundMessage((payload) => {
  const { title, body } = payload.notification;
  const url = payload.data?.url || '/';

  self.registration.showNotification(title || 'Nova Notificação', {
    body: body || '',
    icon: '/icons/favicon.png',
    vibrate: [300, 200, 300, 200, 300],
    data: { url }
  });
});

// Ao clicar na notificação: foca aba existente ou abre nova
self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  const destino = event.notification.data?.url || '/';

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(windowClients => {
      for (const client of windowClients) {
        if (client.url.includes(destino) && 'focus' in client) {
          return client.focus();
        }
      }
      return clients.openWindow(destino);
    })
  );
});
