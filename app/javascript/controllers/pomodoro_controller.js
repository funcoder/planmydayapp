import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pomodoro"
export default class extends Controller {
  static targets = ["timer", "pauseButton", "resumeButton", "taskName"]
  static values = {
    sessionId: Number,
    timerData: Object
  }

  connect() {
    if (this.hasTimerDataValue && this.timerDataValue) {
      this.loadTimerState(this.timerDataValue)
    }
  }

  disconnect() {
    this.stopPolling()
  }

  loadTimerState(data) {
    this.timerDataValue = data
    this.updateDisplay()
    this.updateButtons()

    if (data.state === 'running') {
      this.startPolling()
    } else {
      this.stopPolling()
    }
  }

  async fetchTimerState() {
    if (!this.sessionIdValue) return

    try {
      const response = await fetch(`/focus_sessions/${this.sessionIdValue}`, {
        headers: {
          'Accept': 'application/json',
          'X-CSRF-Token': this.getCSRFToken()
        }
      })

      if (response.ok) {
        const data = await response.json()
        this.loadTimerState(data)
      }
    } catch (error) {
      // Silently handle fetch errors
    }
  }

  async pause() {
    if (!this.sessionIdValue) return

    try {
      const response = await fetch(`/focus_sessions/${this.sessionIdValue}/pause_timer`, {
        method: 'POST',
        headers: {
          'Accept': 'application/json',
          'X-CSRF-Token': this.getCSRFToken()
        }
      })

      if (response.ok) {
        const data = await response.json()
        this.loadTimerState(data)
      }
    } catch (error) {
      // Silently handle pause errors
    }
  }

  async resume() {
    if (!this.sessionIdValue) return

    try {
      const response = await fetch(`/focus_sessions/${this.sessionIdValue}/resume_timer`, {
        method: 'POST',
        headers: {
          'Accept': 'application/json',
          'X-CSRF-Token': this.getCSRFToken()
        }
      })

      if (response.ok) {
        const data = await response.json()
        this.loadTimerState(data)
      }
    } catch (error) {
      // Silently handle resume errors
    }
  }

  async addInterruption() {
    if (!this.sessionIdValue) return

    const button = event.currentTarget
    button.classList.add("animate-bounce")
    setTimeout(() => {
      button.classList.remove("animate-bounce")
    }, 500)

    try {
      await fetch(`/focus_sessions/${this.sessionIdValue}/add_interruption`, {
        method: 'POST',
        headers: {
          'Accept': 'application/json',
          'X-CSRF-Token': this.getCSRFToken()
        }
      })
    } catch (error) {
      // Silently handle interruption errors
    }
  }

  startPolling() {
    this.stopPolling()

    // Update display every 100ms for smooth count-up
    this.displayInterval = setInterval(() => {
      if (this.timerDataValue && this.timerDataValue.state === 'running') {
        const startedAt = new Date(this.timerDataValue.started_at)
        const now = new Date()
        const elapsed = Math.floor((now - startedAt) / 1000) - (this.timerDataValue.total_paused_duration || 0)
        this.updateDisplayWithTime(Math.max(0, elapsed))
      }
    }, 100)

    // Sync with server every 5 seconds
    this.syncInterval = setInterval(() => {
      this.fetchTimerState()
    }, 5000)
  }

  stopPolling() {
    if (this.displayInterval) {
      clearInterval(this.displayInterval)
      this.displayInterval = null
    }
    if (this.syncInterval) {
      clearInterval(this.syncInterval)
      this.syncInterval = null
    }
  }

  updateDisplay() {
    if (!this.timerDataValue) return
    const elapsed = this.timerDataValue.elapsed || 0
    this.updateDisplayWithTime(elapsed)
  }

  updateDisplayWithTime(seconds) {
    if (!this.hasTimerTarget) return

    const minutes = Math.floor(seconds / 60)
    const secs = seconds % 60
    this.timerTarget.textContent = `${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
  }

  updateButtons() {
    if (!this.timerDataValue) return

    if (this.hasPauseButtonTarget) this.pauseButtonTarget.style.display = "none"
    if (this.hasResumeButtonTarget) this.resumeButtonTarget.style.display = "none"

    switch (this.timerDataValue.state) {
      case 'running':
        if (this.hasPauseButtonTarget) this.pauseButtonTarget.style.display = "block"
        break
      case 'paused':
        if (this.hasResumeButtonTarget) this.resumeButtonTarget.style.display = "block"
        break
    }
  }

  getCSRFToken() {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.content : ''
  }
}
