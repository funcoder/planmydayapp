import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["column", "body", "header", "chevron"]

  connect() {
    this.applyMobileState()
    this.mediaQuery = window.matchMedia("(min-width: 768px)")
    this.mediaQuery.addEventListener("change", this.handleResize)
  }

  disconnect() {
    this.mediaQuery?.removeEventListener("change", this.handleResize)
  }

  handleResize = () => {
    this.applyMobileState()
  }

  applyMobileState() {
    const isMobile = !window.matchMedia("(min-width: 768px)").matches

    this.columnTargets.forEach((column, index) => {
      const body = this.bodyTargets[index]
      const chevron = this.chevronTargets[index]
      const isCurrent = column.dataset.current === "true"

      if (isMobile) {
        if (isCurrent) {
          this.expand(body, chevron)
        } else {
          this.collapse(body, chevron)
        }
      } else {
        this.expand(body, chevron)
      }
    })
  }

  toggle(event) {
    const isMobile = !window.matchMedia("(min-width: 768px)").matches
    if (!isMobile) return

    const header = event.currentTarget
    const column = header.closest("[data-time-period-target='column']")
    const index = this.columnTargets.indexOf(column)
    const body = this.bodyTargets[index]
    const chevron = this.chevronTargets[index]

    if (body.classList.contains("hidden")) {
      this.expand(body, chevron)
    } else {
      this.collapse(body, chevron)
    }
  }

  expand(body, chevron) {
    body.classList.remove("hidden")
    chevron?.classList.add("rotate-180")
  }

  collapse(body, chevron) {
    body.classList.add("hidden")
    chevron?.classList.remove("rotate-180")
  }
}
