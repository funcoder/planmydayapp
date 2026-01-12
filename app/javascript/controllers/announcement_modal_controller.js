import { Controller } from "@hotwired/stimulus"

// Announcement modal controller
// Shows new feature announcements on login
export default class extends Controller {
  static targets = ["backdrop", "modal"]
  static values = { shown: Boolean }

  connect() {
    // Show modal on page load if not already shown this session
    if (!this.shownValue && !sessionStorage.getItem('announcementModalShown')) {
      setTimeout(() => this.open(), 500) // Slight delay for better UX
    }
  }

  open() {
    this.backdropTarget.classList.remove('hidden')
    this.modalTarget.classList.remove('hidden')

    // Animate in
    requestAnimationFrame(() => {
      this.backdropTarget.classList.add('opacity-100')
      this.modalTarget.classList.add('opacity-100', 'scale-100')
    })

    // Prevent body scroll
    document.body.style.overflow = 'hidden'
  }

  close() {
    // Mark as shown for this session
    sessionStorage.setItem('announcementModalShown', 'true')

    // Animate out
    this.backdropTarget.classList.remove('opacity-100')
    this.modalTarget.classList.remove('opacity-100', 'scale-100')

    setTimeout(() => {
      this.backdropTarget.classList.add('hidden')
      this.modalTarget.classList.add('hidden')
      document.body.style.overflow = ''
    }, 200)
  }

  markSeenAndClose(event) {
    // Let the form submit, then close
    sessionStorage.setItem('announcementModalShown', 'true')
  }

  stopPropagation(event) {
    event.stopPropagation()
  }
}
