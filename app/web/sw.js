/*
 * Cache für den Start vom Home-Bildschirm.
 *
 * - Seitenaufruf (index.html): erst Netz (max. 3 s), sonst Cache.
 * - Eigene Dateien (Programm, Daten): erst Netz, sonst Cache. Die URLs tragen
 *   keine Version, aus dem Cache käme sonst nach einem Deploy noch die alte
 *   App (so lief nach PR #28 die alte Suche weiter). Der Download bleibt klein:
 *   Der Browser fragt per ETag nach und bekommt "304 unverändert".
 * - Engine und Schriften von den CDNs: URLs enthalten die Version, also sofort
 *   aus dem Cache. Ab dem zweiten Start entfallen mehrere MB.
 * - Nichts wird an Dritte gesendet; zwischengespeichert werden nur GET-Antworten.
 */
'use strict';

const CACHE = 'eo-v2';
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

// Erst Netz, sonst Cache. Mit [timeoutMs] gilt ein langsames Netz als offline,
// aber nur, wenn eine Kopie im Cache liegt.
async function networkFirst(request, timeoutMs) {
  const cache = await caches.open(CACHE);
  const cached = await cache.match(request, { ignoreSearch: true });
  const network = fetch(request).then((response) => {
    if (cacheable(request, response)) cache.put(request, response.clone());
    return response;
  });
  try {
    if (timeoutMs && cached) {
      return await Promise.race([
        network,
        new Promise((_, reject) => setTimeout(() => reject(new Error('timeout')), timeoutMs)),
      ]);
    }
    return await network;
  } catch (e) {
    network.catch(() => undefined);
    if (cached) return cached;
    throw e;
  }
}

// Versionierte CDN-URLs ändern ihren Inhalt nie: Cache zuerst.
async function cacheFirst(request) {
  const cache = await caches.open(CACHE);
  const cached = await cache.match(request);
  if (cached) return cached;
  const response = await fetch(request);
  if (cacheable(request, response)) cache.put(request, response.clone());
  return response;
}

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);
  const sameOrigin = url.origin === self.location.origin;
  if (!sameOrigin && !CDN_HOSTS.includes(url.hostname)) return; // Karten-Kacheln, APIs: nicht anfassen
  if (request.mode === 'navigate') {
    event.respondWith(networkFirst(request, SHELL_TIMEOUT_MS));
    return;
  }
  event.respondWith(sameOrigin ? networkFirst(request) : cacheFirst(request));
});
