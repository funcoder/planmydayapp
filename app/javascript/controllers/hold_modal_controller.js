import { Controller } from "@hotwired/stimulus"

// Hold modal controller for putting tasks on hold with an optional reason
export default class extends Controller {
  static targets = ["modal", "modalContainer", "backdrop", "reasonInput", "form"]

  open(event) {
    event.preventDefault()
    event.stopPropagation()

    const taskUrl = event.currentTarget.dataset.taskUrl

    this.formTarget.action = taskUrl
    this.reasonInputTarget.value = ""

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
    this.close()
  }

  stopPropagation(event) {
    event.stopPropagation()
  }
}
