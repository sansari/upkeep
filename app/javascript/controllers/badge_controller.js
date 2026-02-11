import { Controller } from "@hotwired/stimulus"

// Manages PWA app icon badge and notification permission.
// Attach to <body> so it runs on every page.
export default class extends Controller {
  static targets = ["permissionBanner"]
  static values = {
    pollInterval: { type: Number, default: 300000 }, // 5 minutes
    vapidPublicKey: String
  }

  connect() {
    this.registerServiceWorker()
    this.showPermissionBannerIfNeeded()
    this.updateBadge()
    this.startPolling()
    document.addEventListener("visibilitychange", this.handleVisibilityChange)
  }

  disconnect() {
    this.stopPolling()
    document.removeEventListener("visibilitychange", this.handleVisibilityChange)
  }

  // --- Service Worker Registration ---

  async registerServiceWorker() {
    if (!("serviceWorker" in navigator)) return

    try {
      this.swRegistration = await navigator.serviceWorker.register("/service-worker", { scope: "/" })
    } catch (error) {
      console.warn("Service worker registration failed:", error)
    }
  }

  // --- Badge Logic ---

  async updateBadge() {
    if (!("setAppBadge" in navigator)) return

    try {
      const response = await fetch("/", {
        headers: { "Accept": "application/json" }
      })
      if (!response.ok) return

      const data = await response.json()
      const count = (data.overdue?.length || 0) + (data.due_soon?.length || 0)

      if (count > 0) {
        await navigator.setAppBadge(count)
      } else {
        await navigator.clearAppBadge()
      }
    } catch (error) {
      console.warn("Badge update failed:", error)
    }
  }

  // --- Permission Banner ---

  showPermissionBannerIfNeeded() {
    if (!this.hasPermissionBannerTarget) return
    if (!("Notification" in window)) return
    if (!("setAppBadge" in navigator)) return
    if (Notification.permission !== "default") return
    if (localStorage.getItem("upkeep-badge-dismissed")) return

    this.permissionBannerTarget.style.display = ""
  }

  async requestPermission() {
    if (typeof Notification === "undefined") return

    const result = await Notification.requestPermission()
    this.dismissBanner()

    if (result === "granted") {
      await this.subscribeToPush()
    }

    this.updateBadge()
  }

  dismissBanner() {
    localStorage.setItem("upkeep-badge-dismissed", "true")
    if (this.hasPermissionBannerTarget) {
      this.permissionBannerTarget.style.display = "none"
    }
  }

  // --- Push Subscription ---

  async subscribeToPush() {
    if (!this.swRegistration) return
    if (!this.hasVapidPublicKeyValue) return

    try {
      const existingSub = await this.swRegistration.pushManager.getSubscription()
      if (existingSub) return // already subscribed

      const applicationServerKey = this.urlBase64ToUint8Array(this.vapidPublicKeyValue)
      const subscription = await this.swRegistration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey
      })

      await this.sendSubscriptionToServer(subscription)
    } catch (error) {
      console.warn("Push subscription failed:", error)
    }
  }

  async sendSubscriptionToServer(subscription) {
    const data = subscription.toJSON()

    await fetch("/push_subscriptions", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        endpoint: data.endpoint,
        keys: {
          p256dh: data.keys.p256dh,
          auth: data.keys.auth
        }
      })
    })
  }

  urlBase64ToUint8Array(base64String) {
    const padding = "=".repeat((4 - base64String.length % 4) % 4)
    const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/")
    const rawData = atob(base64)
    const outputArray = new Uint8Array(rawData.length)
    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i)
    }
    return outputArray
  }

  // --- Polling ---

  startPolling() {
    this.pollTimer = setInterval(() => this.updateBadge(), this.pollIntervalValue)
  }

  stopPolling() {
    if (this.pollTimer) {
      clearInterval(this.pollTimer)
      this.pollTimer = null
    }
  }

  handleVisibilityChange = () => {
    if (document.visibilityState === "visible") {
      this.updateBadge()
    }
  }
}
