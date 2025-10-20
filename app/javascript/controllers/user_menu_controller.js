import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="user-menu"
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    console.log("✅ User menu controller connected!", this.element)
    console.log("Menu target found:", this.hasMenuTarget)
    if (this.hasMenuTarget) {
      console.log("Menu element:", this.menuTarget)
    }
  }

  toggle(event) {
    console.log("🖱️ Toggle button clicked!", event)
    event.preventDefault()
    event.stopPropagation()

    if (!this.hasMenuTarget) {
      console.error("❌ Menu target not found!")
      console.log("Available targets:", this.constructor.targets)
      console.log("Element:", this.element)
      return
    }

    console.log("Current menu classes:", this.menuTarget.classList)
    this.menuTarget.classList.toggle("hidden")
    console.log("Menu is now:", this.menuTarget.classList.contains("hidden") ? "hidden" : "visible")
    console.log("New menu classes:", this.menuTarget.classList)
  }

  hide(event) {
    // Don't hide if clicking inside the dropdown element
    if (!this.element.contains(event.target)) {
      if (this.hasMenuTarget) {
        this.menuTarget.classList.add("hidden")
      }
    }
  }

  disconnect() {
    console.log("❌ User menu controller disconnected!")
    if (this.hideHandler) {
      document.removeEventListener("click", this.hideHandler)
    }
  }
}
