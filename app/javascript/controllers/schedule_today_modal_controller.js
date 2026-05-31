import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["backdrop", "modalContainer", "modal", "form", "timeOfDayInput", "title"]

  open(event) {
    event.preventDefault()
    event.stopPropagation()

    const taskUrl = event.currentTarget.dataset.taskUrl
    const taskTitle = event.currentTarget.dataset.taskTitle || "this task"

    this.formTarget.action = taskUrl
    this.timeOfDayInputTarget.value = "morning"
    this.titleTarget.textContent = taskTitle

    this.backdropTarget.classList.remove("hidden")
    this.modalContainerTarget.classList.remove("hidden")

    requestAnimationFrame(() => {
      this.backdropTarget.classList.add("opacity-100")
      this.modalTarget.classList.add("opacity-100", "scale-100")
    })

    document.body.style.overflow = "hidden"
  }

  close() {
    this.backdropTarget.classList.remove("opacity-100")
    this.modalTarget.classList.remove("opacity-100", "scale-100")

    setTimeout(() => {
      this.backdropTarget.classList.add("hidden")
      this.modalContainerTarget.classList.add("hidden")
      document.body.style.overflow = ""
    }, 200)
  }

  choose(event) {
    event.preventDefault()
    this.timeOfDayInputTarget.value = event.currentTarget.dataset.timeOfDay
    this.formTarget.requestSubmit()
  }

  stopPropagation(event) {
    event.stopPropagation()
  }
}
