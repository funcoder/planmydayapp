import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "banner"]
  static values = { banner: Boolean }

  connect() {
    this.deferredPrompt = null

    // Check if banner was previously dismissed
    if (this.bannerValue && this.wasBannerDismissed()) {
      return
    }

    window.addEventListener('beforeinstallprompt', (e) => {
      // Prevent the mini-infobar from appearing on mobile
      e.preventDefault()
      // Store the event so it can be triggered later
      this.deferredPrompt = e
      console.log('beforeinstallprompt event fired - app is installable!')
      this.showInstallUI()
    })

    window.addEventListener('appinstalled', () => {
      console.log('PWA was installed')
      this.deferredPrompt = null
      this.hideInstallUI()
    })
  }

  showInstallUI() {
    console.log('Showing install UI', { bannerValue: this.bannerValue, hasBanner: this.hasBannerTarget, hasButton: this.hasButtonTarget })

    // Show banner if this is the banner controller
    if (this.bannerValue && this.hasBannerTarget) {
      this.bannerTarget.classList.remove('hidden')
    }

    // Show button if this is the profile page button
    if (!this.bannerValue && this.hasButtonTarget) {
      this.buttonTarget.classList.remove('hidden')
    }
  }

  hideInstallUI() {
    if (this.hasBannerTarget) {
      this.bannerTarget.classList.add('hidden')
    }
    if (this.hasButtonTarget) {
      this.buttonTarget.classList.add('hidden')
    }
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

    // Hide all install UI
    this.hideInstallUI()
  }

  dismissBanner() {
    if (this.hasBannerTarget) {
      this.bannerTarget.classList.add('hidden')
    }
    // Store dismissal in localStorage
    localStorage.setItem('pwa-install-banner-dismissed', Date.now())
  }

  wasBannerDismissed() {
    const dismissedAt = localStorage.getItem('pwa-install-banner-dismissed')
    if (!dismissedAt) return false

    // Show banner again after 7 days
    const sevenDays = 7 * 24 * 60 * 60 * 1000
    return (Date.now() - parseInt(dismissedAt)) < sevenDays
  }
}
