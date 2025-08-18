import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    // Close dropdown when clicking outside
    this.boundCloseDropdown = this.closeDropdown.bind(this)
    document.addEventListener("click", this.boundCloseDropdown)
  }

  disconnect() {
    document.removeEventListener("click", this.boundCloseDropdown)
  }

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle("hidden")
  }

  closeDropdown(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }
}