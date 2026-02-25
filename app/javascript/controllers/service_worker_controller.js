import { Controller } from "@hotwired/stimulus"

// Version must be updated when service worker changes
const SW_VERSION = 'v0.2.5'

export default class extends Controller {
  static targets = ["updateBanner"]

  connect() {
    this.registerServiceWorker()
  }

  async registerServiceWorker() {
    if (!('serviceWorker' in navigator)) return

    try {
      // First, unregister any old service workers to clear stale caches
      const registrations = await navigator.serviceWorker.getRegistrations()
      for (const registration of registrations) {
        // Check if it's an old registration (different URL or needs refresh)
        const oldSwUrl = registration.active?.scriptURL || ''
        if (!oldSwUrl.includes(`sw-${SW_VERSION}`)) {
          await registration.unregister()
        }
      }

      // Register with versioned URL to bust browser cache
      const swUrl = `/service-worker.js?sw-${SW_VERSION}`
      const registration = await navigator.serviceWorker.register(swUrl, {
        updateViaCache: 'none' // Never use HTTP cache for service worker
      })

      // Check for updates on visibility change
      document.addEventListener('visibilitychange', () => {
        if (document.visibilityState === 'visible') {
          registration.update()
        }
      })

      // Handle updates
      registration.addEventListener('updatefound', () => {
        const newWorker = registration.installing

        newWorker.addEventListener('statechange', () => {
          if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
            // Tell the new service worker to take over immediately
            newWorker.postMessage({ type: 'SKIP_WAITING' })
          }
        })
      })

      // Show update banner when new service worker takes control
      navigator.serviceWorker.addEventListener('controllerchange', () => {
        this.showUpdateBanner()
      })

    } catch (error) {
      // Service worker registration failed silently
    }
  }

  showUpdateBanner() {
    if (this.hasUpdateBannerTarget) {
      this.updateBannerTarget.classList.remove('hidden')
    }
  }

  refreshPage() {
    window.location.reload()
  }

  dismissUpdate() {
    if (this.hasUpdateBannerTarget) {
      this.updateBannerTarget.classList.add('hidden')
    }
  }
}
