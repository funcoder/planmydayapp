import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pomodoro"
export default class extends Controller {
  static targets = ["timer", "startButton", "pauseButton", "resumeButton", "resetButton", "taskName"]
  static values = {
    sessionId: Number,
    timerData: Object
  }

  connect() {
    // Initialize from server data if available
    if (this.hasTimerDataValue && this.timerDataValue) {
      this.loadTimerState(this.timerDataValue)
    }

    // Request notification permission
    if ("Notification" in window && Notification.permission === "default") {
      Notification.requestPermission()
    }

    // Start polling for updates if timer is running
    if (this.timerDataValue && this.timerDataValue.state === 'running') {
      this.startPolling()
    }
  }

  disconnect() {
    this.stopPolling()
  }

  loadTimerState(data) {
    this.timerDataValue = data
    this.updateDisplay()
    this.updateButtons()

    // If timer is running, calculate elapsed time and start ticking
    if (data.state === 'running') {
      this.startPolling()
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
      console.error('Error fetching timer state:', error)
    }
  }

  async start() {
    if (!this.sessionIdValue) return

    try {
      const response = await fetch(`/focus_sessions/${this.sessionIdValue}/start_timer`, {
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
      console.error('Error starting timer:', error)
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
      console.error('Error pausing timer:', error)
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
      console.error('Error resuming timer:', error)
    }
  }

  async reset() {
    if (!this.sessionIdValue) return

    try {
      const response = await fetch(`/focus_sessions/${this.sessionIdValue}/stop_timer`, {
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
      console.error('Error stopping timer:', error)
    }
  }

  async addInterruption() {
    if (!this.sessionIdValue) return

    // Visual feedback
    const button = event.currentTarget
    button.classList.add("animate-bounce")
    setTimeout(() => {
      button.classList.remove("animate-bounce")
    }, 500)

    try {
      const response = await fetch(`/focus_sessions/${this.sessionIdValue}/add_interruption`, {
        method: 'POST',
        headers: {
          'Accept': 'application/json',
          'X-CSRF-Token': this.getCSRFToken()
        }
      })

      if (response.ok) {
        const data = await response.json()
        // Update interruption count if displayed
      }
    } catch (error) {
      console.error('Error adding interruption:', error)
    }
  }

  startPolling() {
    this.stopPolling() // Clear any existing interval

    // Update display every 100ms for smooth countdown
    this.displayInterval = setInterval(() => {
      if (this.timerDataValue && this.timerDataValue.state === 'running') {
        // Calculate remaining time based on server data and elapsed time
        const startedAt = new Date(this.timerDataValue.started_at)
        const now = new Date()
        const elapsed = Math.floor((now - startedAt) / 1000) - (this.timerDataValue.total_paused_duration || 0)
        const remaining = Math.max(0, this.timerDataValue.duration - elapsed)

        this.updateDisplayWithTime(remaining)

        if (remaining <= 0) {
          this.complete()
        }

        // Add urgency styling in last minute
        if (remaining <= 60 && this.hasTimerTarget) {
          this.timerTarget.classList.add("text-red-600", "animate-pulse")
        }
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

    const remaining = this.timerDataValue.remaining || this.timerDataValue.duration
    this.updateDisplayWithTime(remaining)
  }

  updateDisplayWithTime(seconds) {
    if (!this.hasTimerTarget) return

    const minutes = Math.floor(seconds / 60)
    const secs = seconds % 60
    this.timerTarget.textContent = `${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
  }

  updateButtons() {
    if (!this.timerDataValue) return

    // Hide all buttons first
    if (this.hasStartButtonTarget) this.startButtonTarget.style.display = "none"
    if (this.hasPauseButtonTarget) this.pauseButtonTarget.style.display = "none"
    if (this.hasResumeButtonTarget) this.resumeButtonTarget.style.display = "none"

    // Show appropriate button based on state
    switch (this.timerDataValue.state) {
      case 'stopped':
        if (this.hasStartButtonTarget) this.startButtonTarget.style.display = "block"
        break
      case 'running':
        if (this.hasPauseButtonTarget) this.pauseButtonTarget.style.display = "block"
        break
      case 'paused':
        if (this.hasResumeButtonTarget) this.resumeButtonTarget.style.display = "block"
        break
    }
  }

  complete() {
    this.stopPolling()
    this.playSound()
    this.showNotification()

    // Remove urgency styling
    if (this.hasTimerTarget) {
      this.timerTarget.classList.remove("text-red-600", "animate-pulse")
    }

    // Mark session as complete via AJAX
    this.endSession()
  }

  async endSession() {
    if (!this.sessionIdValue) return

    try {
      await fetch(`/focus_sessions/${this.sessionIdValue}/end_session`, {
        method: 'POST',
        headers: {
          'Accept': 'application/json',
          'X-CSRF-Token': this.getCSRFToken()
        }
      })
    } catch (error) {
      console.error('Error ending session:', error)
    }
  }

  playSound() {
    const audioContext = new (window.AudioContext || window.webkitAudioContext)()
    const oscillator = audioContext.createOscillator()
    const gainNode = audioContext.createGain()

    oscillator.connect(gainNode)
    gainNode.connect(audioContext.destination)

    oscillator.frequency.value = 800
    gainNode.gain.value = 0.1

    oscillator.start()
    oscillator.stop(audioContext.currentTime + 0.2)
  }

  showNotification() {
    if ("Notification" in window && Notification.permission === "granted") {
      new Notification("Pomodoro Complete! 🎉", {
        body: "Great job focusing! Time for a break.",
        icon: "/icon.png"
      })
    }
  }

  getCSRFToken() {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.content : ''
  }
}