import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pomodoro"
export default class extends Controller {
  static targets = ["timer", "startButton", "pauseButton", "resetButton", "taskName"]
  static values = {
    duration: { type: Number, default: 25 * 60 }, // 25 minutes in seconds
    timeRemaining: Number,
    running: { type: Boolean, default: false },
    sessionId: Number
  }

  connect() {
    this.timeRemainingValue = this.durationValue
    this.startTime = null
    this.pausedDuration = 0
    this.updateDisplay()
    
    // Request notification permission
    if ("Notification" in window && Notification.permission === "default") {
      Notification.requestPermission()
    }
  }

  disconnect() {
    if (this.timer) {
      clearInterval(this.timer)
    }
  }

  start() {
    if (this.runningValue) return

    this.runningValue = true
    this.startButtonTarget.style.display = "none"
    this.pauseButtonTarget.style.display = "inline-flex"

    // Track start time for accurate timing even in background tabs
    if (!this.startTime) {
      this.startTime = Date.now()
    } else {
      // Resuming from pause
      this.startTime = Date.now() - this.pausedDuration
    }

    // Update more frequently for smoother display
    this.timer = setInterval(() => {
      this.tick()
    }, 100) // Check every 100ms for more accurate timing

    // Create focus session via AJAX if we have a task
    if (this.sessionIdValue) {
      // Session already exists, just continue
    } else {
      // Would create new session here via fetch to focus_sessions#create
    }
  }

  pause() {
    this.runningValue = false
    clearInterval(this.timer)
    
    // Store how much time has passed so we can resume correctly
    if (this.startTime) {
      this.pausedDuration = Date.now() - this.startTime
    }
    
    this.pauseButtonTarget.style.display = "none"
    this.startButtonTarget.style.display = "inline-flex"
  }

  reset() {
    this.pause()
    this.timeRemainingValue = this.durationValue
    this.startTime = null
    this.pausedDuration = 0
    this.updateDisplay()
  }

  tick() {
    // Calculate actual elapsed time instead of relying on interval
    const elapsed = Math.floor((Date.now() - this.startTime) / 1000)
    this.timeRemainingValue = Math.max(0, this.durationValue - elapsed)

    if (this.timeRemainingValue <= 0) {
      this.complete()
    } else {
      this.updateDisplay()
      
      // Add urgency styling in last minute
      if (this.timeRemainingValue <= 60) {
        this.timerTarget.classList.add("text-red-600", "animate-pulse")
      }
    }
  }

  complete() {
    this.pause()
    this.playSound()
    this.showNotification()
    
    // Reset for next session
    this.timeRemainingValue = this.durationValue
    this.startTime = null
    this.pausedDuration = 0
    this.updateDisplay()
    this.timerTarget.classList.remove("text-red-600", "animate-pulse")
    
    // Would mark session as complete via AJAX here
  }

  updateDisplay() {
    const minutes = Math.floor(this.timeRemainingValue / 60)
    const seconds = this.timeRemainingValue % 60
    this.timerTarget.textContent = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
  }

  playSound() {
    // Create a simple beep sound
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

  addInterruption() {
    // Visual feedback
    const button = event.currentTarget
    button.classList.add("animate-bounce")
    setTimeout(() => {
      button.classList.remove("animate-bounce")
    }, 500)
    
    // Would record interruption via AJAX here
  }
}