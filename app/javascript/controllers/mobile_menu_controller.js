import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mobile-menu"
export default class extends Controller {
  static targets = ["menu", "burger"]
  
  connect() {
    console.log("Mobile menu controller connected")
    console.log("Menu target:", this.hasMenuTarget ? "found" : "not found")
  }
  
  toggle() {
    console.log("Toggle clicked")
    if (this.hasMenuTarget) {
      this.menuTarget.classList.toggle("hidden")
      console.log("Menu toggled, hidden class:", this.menuTarget.classList.contains("hidden"))
    } else {
      console.error("Menu target not found")
    }
    
    // Toggle burger icon animation
    if (this.hasBurgerTarget) {
      this.burgerTarget.classList.toggle("open")
    }
  }
  
  close() {
    this.menuTarget.classList.add("hidden")
    if (this.hasBurgerTarget) {
      this.burgerTarget.classList.remove("open")
    }
  }
}
