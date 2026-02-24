import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["statusSelect", "reasonField"]

  toggle() {
    const isOnHold = this.statusSelectTarget.value === "on_hold"
    this.reasonFieldTarget.classList.toggle("hidden", !isOnHold)
  }
}
