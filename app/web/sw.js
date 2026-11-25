/*
 * Cache für den Start vom Home-Bildschirm.
 *
 * - Seitenaufruf (index.html): erst Netz (max. 3 s), sonst Cache. So kommen
 *   neue Versionen sofort an, offline startet die App trotzdem.
 * - Programm, Engine, Schriften, Daten: sofort aus dem Cache, im Hintergrund
 *   aktualisieren (stale-while-revalidate). Ab dem zweiten Start entfällt der
 *   Download von mehreren MB.
 * - Nichts wird an Dritte gesendet; zwischengespeichert werden nur GET-Antworten.
 */
'use strict';

const CACHE = 'eo-v1';
const SHELL_TIMEOUT_MS = 3000;
// Flutter-Engine und Schriften kommen von Google-CDNs, URLs enthalten die Version
const CDN_HOSTS = ['www.gstatic.com', 'fonts.gstatic.com', 'fonts.googleapis.com', 'cdn.jsdelivr.net'];

self.addEventListener('install', () => self.skipWaiting());

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)));
    await self.clients.claim();
  })());
});

function cacheable(request, response) {
  return request.method === 'GET' && response && (response.ok || response.type === 'opaque');
}

async function networkFirst(request) {
  const cache = await caches.open(CACHE);
  try {
    const response = await Promise.race([
      fetch(request),
      new Promise((_, reject) => setTimeout(() => reject(new Error('timeout')), SHELL_TIMEOUT_MS)),
    ]);
    if (cacheable(request, response)) cache.put(request, response.clone());
    return response;
  } catch (e) {
    const cached = await cache.match(request, { ignoreSearch: true });
    if (cached) return cached;
    throw e;
  }
}

async function staleWhileRevalidate(event) {
  const cache = await caches.open(CACHE);
  const cached = await cache.match(event.request);
  const update = fetch(event.request).then((response) => {
    if (cacheable(event.request, response)) cache.put(event.request, response.clone());
    return response;
  });
  if (cached) {
    event.waitUntil(update.catch(() => undefined));
    return cached;
  }
  return update;
}

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);
  const sameOrigin = url.origin === self.location.origin;
  if (!sameOrigin && !CDN_HOSTS.includes(url.hostname)) return; // Karten-Kacheln, APIs: nicht anfassen
  if (request.mode === 'navigate') {
    event.respondWith(networkFirst(request));
    return;
  }
  event.respondWith(staleWhileRevalidate(event));
});
