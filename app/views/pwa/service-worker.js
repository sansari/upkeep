// Service worker for PWA badge and push notification support.

self.addEventListener("install", (event) => {
  self.skipWaiting()
})

self.addEventListener("activate", (event) => {
  event.waitUntil(clients.claim())
})

// --- Push Notifications ---

self.addEventListener("push", (event) => {
  const data = event.data ? event.data.json() : {}
  const count = data.count || 0
  const message = data.message || "Tasks need attention"

  event.waitUntil(
    Promise.all([
      self.registration.showNotification("Upkeep", {
        body: message,
        icon: "/icon.png",
        badge: "/icon.png",
        data: { url: "/" }
      }),
      count > 0 ? navigator.setAppBadge(count) : navigator.clearAppBadge()
    ])
  )
})

self.addEventListener("notificationclick", (event) => {
  event.notification.close()

  const url = event.notification.data?.url || "/"

  event.waitUntil(
    clients.matchAll({ type: "window", includeUncontrolled: true }).then((clientList) => {
      for (const client of clientList) {
        if (client.url.includes(self.location.origin) && "focus" in client) {
          return client.focus()
        }
      }
      return clients.openWindow(url)
    })
  )
})
