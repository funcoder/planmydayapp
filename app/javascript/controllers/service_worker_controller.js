import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.registerServiceWorker()
  }

  registerServiceWorker() {
    if ('serviceWorker' in navigator) {
      window.addEventListener('load', async () => {
        try {
          const registration = await navigator.serviceWorker.register('/service-worker.js')
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
                // New version available - it will activate on next page load
                console.log('New version available')
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
      })
    }
  }
}
