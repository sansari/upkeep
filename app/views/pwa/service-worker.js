// Minimal service worker for PWA qualification and badge support.
// No complex caching — this is a simple status dashboard.

self.addEventListener("install", (event) => {
  self.skipWaiting()
})

self.addEventListener("activate", (event) => {
  event.waitUntil(clients.claim())
})
