import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.deferredPrompt = null

    window.addEventListener('beforeinstallprompt', (e) => {
      // Prevent the mini-infobar from appearing on mobile
      e.preventDefault()
      // Store the event so it can be triggered later
      this.deferredPrompt = e
      // Show the install button
      if (this.hasButtonTarget) {
        this.buttonTarget.classList.remove('hidden')
      }
    })

    window.addEventListener('appinstalled', () => {
      console.log('PWA was installed')
      // Hide the install button
      if (this.hasButtonTarget) {
        this.buttonTarget.classList.add('hidden')
      }
      this.deferredPrompt = null
    })
  }

  async install() {
    if (!this.deferredPrompt) {
      console.log('Install prompt not available')
      return
    }

    // Show the install prompt
    this.deferredPrompt.prompt()

    // Wait for the user to respond to the prompt
    const { outcome } = await this.deferredPrompt.userChoice

    console.log(`User response to the install prompt: ${outcome}`)

    // Clear the deferredPrompt
    this.deferredPrompt = null

    // Hide the install button
    if (this.hasButtonTarget) {
      this.buttonTarget.classList.add('hidden')
    }
  }
}
