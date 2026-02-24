import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["projectSelect", "colorRadio"]
  static values = { colors: Object }

  selectProject() {
    const projectId = this.projectSelectTarget.value
    if (!projectId) return

    const projectColor = this.colorsValue[projectId]
    if (!projectColor) return

    const radio = this.element.querySelector(`input[type="radio"][value="${projectColor}"]`)
    if (radio) {
      radio.checked = true
    }
  }
}
