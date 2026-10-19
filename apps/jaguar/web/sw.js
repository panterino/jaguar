// Jaguar sin conexión. Primero la red, para que siempre se vea la versión
// nueva; si no hay internet, lo último que se guardó. Las clases y la
// comunidad (Firestore y Auth) nunca pasan por aquí.
const CACHE = 'jaguar';

self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => event.waitUntil(self.clients.claim()));

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);
  if (!url.protocol.startsWith('http')) return;
  if (url.hostname.endsWith('googleapis.com') && !url.hostname.startsWith('fonts.')) return;

  event.respondWith(
    fetch(request)
      .then((response) => {
        if (response.ok || response.type === 'opaque') {
          const copy = response.clone();
          caches.open(CACHE).then((cache) => cache.put(request, copy));
        }
        return response;
      })
      .catch(async () => {
        const navigation = request.mode === 'navigate';
        const cached = await caches.match(request, { ignoreSearch: navigation });
        return cached || (navigation ? caches.match('index.html', { ignoreSearch: true }) : Response.error());
      }),
  );
});
