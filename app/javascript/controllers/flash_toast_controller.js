import { Controller } from "@hotwired/stimulus"

// Auto-dismiss flash toast with countdown progress bar.
export default class extends Controller {
  static targets = ["progress"]
  static values = { duration: { type: Number, default: 5000 } }

  connect() {
    this.startTime = performance.now()
    this.closed = false
    this.tick = this.tick.bind(this)
    this.frame = requestAnimationFrame(this.tick)
  }

  disconnect() {
    if (this.frame) cancelAnimationFrame(this.frame)
  }

  dismiss() {
    this.close()
  }

  tick(now) {
    if (this.closed) return

    const elapsed = now - this.startTime
    const remaining = Math.max(0, this.durationValue - elapsed)
    const ratio = remaining / this.durationValue

    if (this.hasProgressTarget) {
      this.progressTarget.style.transform = `scaleX(${ratio})`
    }

    if (remaining <= 0) {
      this.close()
      return
    }

    this.frame = requestAnimationFrame(this.tick)
  }

  close() {
    if (this.closed) return
    this.closed = true
    if (this.frame) cancelAnimationFrame(this.frame)

    this.element.classList.add("transition-all", "duration-200", "opacity-0", "translate-y-2")
    setTimeout(() => this.element.remove(), 220)
  }
}
