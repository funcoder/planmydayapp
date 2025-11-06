import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.registerServiceWorker()
  }

  registerServiceWorker() {
    if ('serviceWorker' in navigator) {
      window.addEventListener('load', () => {
        navigator.serviceWorker.register('/service-worker.js')
          .then(registration => {
            console.log('ServiceWorker registered:', registration)
          })
          .catch(error => {
            console.log('ServiceWorker registration failed:', error)
          })
      })
    }
  }
}
