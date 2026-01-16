import { Controller } from "@hotwired/stimulus"

// Date picker modal controller for moving tasks to another date
export default class extends Controller {
  static targets = ["modal", "modalContainer", "backdrop", "dateInput", "form"]
  static values = { taskId: Number }

  open(event) {
    event.preventDefault()
    event.stopPropagation()

    const taskId = event.currentTarget.dataset.taskId
    const taskUrl = event.currentTarget.dataset.taskUrl

    this.taskIdValue = taskId
    this.formTarget.action = taskUrl

    // Set default date to tomorrow
    const tomorrow = new Date()
    tomorrow.setDate(tomorrow.getDate() + 1)
    this.dateInputTarget.value = tomorrow.toISOString().split('T')[0]
    this.dateInputTarget.min = new Date().toISOString().split('T')[0]

    this.backdropTarget.classList.remove('hidden')
    this.modalContainerTarget.classList.remove('hidden')

    requestAnimationFrame(() => {
      this.backdropTarget.classList.add('opacity-100')
      this.modalTarget.classList.add('opacity-100', 'scale-100')
    })

    document.body.style.overflow = 'hidden'
  }

  close() {
    this.backdropTarget.classList.remove('opacity-100')
    this.modalTarget.classList.remove('opacity-100', 'scale-100')

    setTimeout(() => {
      this.backdropTarget.classList.add('hidden')
      this.modalContainerTarget.classList.add('hidden')
      document.body.style.overflow = ''
    }, 200)
  }

  submit(event) {
    // Form will submit normally with Turbo
    this.close()
  }

  stopPropagation(event) {
    event.stopPropagation()
  }
}
