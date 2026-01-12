import { Controller } from "@hotwired/stimulus"

// Version must be updated when service worker changes
const SW_VERSION = 'v7'

export default class extends Controller {
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
          console.log('Unregistering old service worker:', oldSwUrl)
          await registration.unregister()
        }
      }

      // Register with versioned URL to bust browser cache
      const swUrl = `/service-worker.js?sw-${SW_VERSION}`
      const registration = await navigator.serviceWorker.register(swUrl, {
        updateViaCache: 'none' // Never use HTTP cache for service worker
      })
      console.log('ServiceWorker registered:', registration)

      // Check for updates immediately
      registration.update()

      // Check for updates periodically (every 60 seconds)
      setInterval(() => {
        registration.update()
      }, 60000)

      // Handle updates
      registration.addEventListener('updatefound', () => {
        const newWorker = registration.installing
        console.log('New service worker installing...')

        newWorker.addEventListener('statechange', () => {
          if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
            console.log('New version available, activating...')
            // Tell the new service worker to take over immediately
            newWorker.postMessage({ type: 'SKIP_WAITING' })
          }
        })
      })

      // When the new service worker takes over, refresh the page
      let refreshing = false
      navigator.serviceWorker.addEventListener('controllerchange', () => {
        if (!refreshing) {
          refreshing = true
          console.log('Service worker updated, refreshing page...')
          window.location.reload()
        }
      })

    } catch (error) {
      console.log('ServiceWorker registration failed:', error)
    }
  }
}
