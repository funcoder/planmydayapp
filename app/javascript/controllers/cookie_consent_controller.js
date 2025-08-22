import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["banner"]
  
  connect() {
    console.log("Cookie consent controller connected")
    // Check if user has already consented
    if (!this.hasConsented()) {
      console.log("No consent found, showing banner")
      this.show()
    } else {
      console.log("Consent already given")
    }
  }
  
  accept() {
    // Set cookie for 1 year
    this.setCookie("cookie_consent", "accepted", 365)
    this.hide()
  }
  
  decline() {
    // Set cookie for 30 days for declined
    this.setCookie("cookie_consent", "declined", 30)
    this.hide()
  }
  
  show() {
    console.log("Showing banner", this.bannerTarget)
    this.bannerTarget.classList.remove("hidden")
  }
  
  hide() {
    console.log("Hiding banner")
    this.bannerTarget.classList.add("hidden")
  }
  
  hasConsented() {
    return this.getCookie("cookie_consent") !== null
  }
  
  setCookie(name, value, days) {
    const date = new Date()
    date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000))
    const expires = "expires=" + date.toUTCString()
    document.cookie = name + "=" + value + ";" + expires + ";path=/;SameSite=Lax"
  }
  
  getCookie(name) {
    const nameEQ = name + "="
    const ca = document.cookie.split(';')
    for(let i = 0; i < ca.length; i++) {
      let c = ca[i]
      while (c.charAt(0) == ' ') c = c.substring(1, c.length)
      if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length)
    }
    return null
  }
}