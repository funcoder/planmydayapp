import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "status", "review", "title", "description", "destinationButton", "backdrop", "modalContainer", "modal"]
  static values = {
    transcribeUrl: String,
    quickAddUrl: String,
    maxDurationSeconds: { type: Number, default: 30 },
    recording: { type: Boolean, default: false }
  }

  connect() {
    this.audioChunks = []
    this.recorder = null
    this.stream = null
    this.transcript = ""
    this.recordingStartedAt = null
    this.autoStopTimer = null

    if (!navigator.mediaDevices?.getUserMedia || !window.MediaRecorder) {
      this.disable("Voice capture isn't supported in this browser.")
    }
  }

  disconnect() {
    this.clearAutoStopTimer()
    this.stopStream()
  }

  open(event) {
    event?.preventDefault()
    event?.stopPropagation()

    this.resetState()
    this.backdropTarget.classList.remove("hidden")
    this.modalContainerTarget.classList.remove("hidden")

    requestAnimationFrame(() => {
      this.backdropTarget.classList.add("opacity-100")
      this.modalTarget.classList.add("opacity-100", "translate-y-0", "scale-100")
    })

    document.body.style.overflow = "hidden"
  }

  close() {
    if (this.recordingValue) {
      this.stopRecording()
    }

    this.backdropTarget.classList.remove("opacity-100")
    this.modalTarget.classList.remove("opacity-100", "translate-y-0", "scale-100")

    setTimeout(() => {
      this.modalContainerTarget.classList.add("hidden")
      this.backdropTarget.classList.add("hidden")
      document.body.style.overflow = ""
      this.resetState()
    }, 200)
  }

  stopPropagation(event) {
    event.stopPropagation()
  }

  async toggle() {
    if (this.recordingValue) {
      this.stopRecording()
      return
    }

    this.hideReview()
    this.setButtonState("Preparing...", { active: false, disabled: true })
    this.setStatus("Preparing microphone. Wait for the recording message, then speak.")

    try {
      this.stream = await navigator.mediaDevices.getUserMedia({ audio: true })
      this.audioChunks = []

      const mimeType = this.supportedMimeType()
      this.recorder = mimeType ? new MediaRecorder(this.stream, { mimeType }) : new MediaRecorder(this.stream)

      this.recorder.addEventListener("dataavailable", (event) => {
        if (event.data.size > 0) this.audioChunks.push(event.data)
      })

      this.recorder.addEventListener("start", () => {
        this.recordingValue = true
        this.startAutoStopTimer()
        this.setButtonState("Stop Recording", { active: true, disabled: false })
        this.setStatus("Recording now. Start speaking.")
      })

      this.recorder.addEventListener("stop", () => this.transcribe())
      await this.sleep(350)
      this.recorder.start()
    } catch (error) {
      console.error("Unable to start recording", error)
      this.setButtonState("Record Task", { active: false, disabled: false })
      this.setStatus("Microphone access was blocked.")
    }
  }

  stopRecording() {
    if (!this.recorder || this.recorder.state === "inactive") return

    this.clearAutoStopTimer()
    this.recorder.stop()
    this.recordingValue = false
    this.setButtonState("Transcribing...", { active: false, disabled: true })
    this.setStatus("Transcribing your task...")
  }

  async transcribe() {
    try {
      const audioBlob = new Blob(this.audioChunks, { type: this.recorder?.mimeType || "audio/webm" })
      const formData = new FormData()
      formData.append("audio", audioBlob, this.fileNameFor(audioBlob.type))
      formData.append("duration_seconds", this.recordingDurationSeconds.toString())

      const response = await fetch(this.transcribeUrlValue, {
        method: "POST",
        headers: {
          "X-CSRF-Token": this.csrfToken,
          "Accept": "application/json"
        },
        body: formData,
        credentials: "same-origin"
      })

      const payload = await response.json()

      if (!response.ok) {
        throw new Error(payload.error || "Transcription failed.")
      }

      this.transcript = payload.transcript
      this.populateReview(payload.task)
      this.setButtonState("Record Again", { active: false, disabled: false })
      this.setStatus("Where should this go?")
    } catch (error) {
      console.error("Unable to transcribe recording", error)
      this.setStatus(error.message)
      this.setButtonState("Record Task", { active: false, disabled: false })
    } finally {
      this.audioChunks = []
      this.recorder = null
      this.stopStream()
    }
  }

  async chooseDestination(event) {
    const destination = event.currentTarget.dataset.destination
    if (!this.transcript) return

    this.setDestinationButtonsDisabled(true)
    this.setStatus(`Adding to ${destination}...`)

    try {
      const response = await fetch(this.quickAddUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken,
          "Accept": "application/json"
        },
        body: JSON.stringify({
          transcript: this.transcript,
          destination
        }),
        credentials: "same-origin"
      })

      const payload = await response.json()

      if (!response.ok) {
        throw new Error(payload.error || "Unable to add the task.")
      }

      this.setStatus(payload.notice || "Task added.")
      window.location.reload()
    } catch (error) {
      console.error("Unable to add quick task", error)
      this.setStatus(error.message)
      this.setDestinationButtonsDisabled(false)
    }
  }

  populateReview(task) {
    if (this.hasTitleTarget) {
      this.titleTarget.textContent = task.title || "Untitled task"
    }

    if (this.hasDescriptionTarget) {
      this.descriptionTarget.textContent = task.description || "No extra details"
      this.descriptionTarget.classList.toggle("hidden", !task.description)
    }

    this.reviewTarget.classList.remove("hidden")
  }

  hideReview() {
    if (this.hasReviewTarget) {
      this.reviewTarget.classList.add("hidden")
    }
    this.setDestinationButtonsDisabled(false)
  }

  resetState() {
    this.transcript = ""
    this.audioChunks = []
    this.recorder = null
    this.recordingValue = false
    this.recordingStartedAt = null
    this.clearAutoStopTimer()
    this.stopStream()
    this.hideReview()
    this.setButtonState("Record Task", { active: false, disabled: false })
    this.setStatus(`Tap record, speak naturally, then choose Backlog, Morning, Afternoon, or Evening. Limit ${this.maxDurationSecondsValue}s.`)

    if (this.hasTitleTarget) this.titleTarget.textContent = ""
    if (this.hasDescriptionTarget) {
      this.descriptionTarget.textContent = ""
      this.descriptionTarget.classList.remove("hidden")
    }
  }

  setDestinationButtonsDisabled(disabled) {
    this.destinationButtonTargets.forEach((button) => {
      button.disabled = disabled
    })
  }

  setButtonState(label, { active = false, disabled = false } = {}) {
    if (!this.hasButtonTarget) return

    this.buttonTarget.textContent = label
    this.buttonTarget.classList.toggle("animate-pulse", active)
    this.buttonTarget.disabled = disabled
  }

  setStatus(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
    }
  }

  disable(message) {
    if (this.hasButtonTarget) {
      this.buttonTarget.disabled = true
      this.buttonTarget.classList.add("opacity-50", "cursor-not-allowed")
    }

    this.setStatus(message)
  }

  stopStream() {
    this.stream?.getTracks()?.forEach((track) => track.stop())
    this.stream = null
  }

  startAutoStopTimer() {
    this.clearAutoStopTimer()
    this.recordingStartedAt = Date.now()
    this.autoStopTimer = window.setTimeout(() => {
      if (this.recordingValue) {
        this.setStatus(`Reached ${this.maxDurationSecondsValue}s limit. Finishing recording...`)
        this.stopRecording()
      }
    }, this.maxDurationSecondsValue * 1000)
  }

  clearAutoStopTimer() {
    if (this.autoStopTimer) {
      window.clearTimeout(this.autoStopTimer)
      this.autoStopTimer = null
    }
  }

  supportedMimeType() {
    const candidates = ["audio/webm", "audio/mp4", "audio/ogg"]
    return candidates.find((type) => MediaRecorder.isTypeSupported(type))
  }

  fileNameFor(mimeType) {
    if (mimeType.includes("mp4")) return "task-note.m4a"
    if (mimeType.includes("ogg")) return "task-note.ogg"
    return "task-note.webm"
  }

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content || ""
  }

  sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms))
  }

  get recordingDurationSeconds() {
    if (!this.recordingStartedAt) return 0

    return Math.max(1, Math.ceil((Date.now() - this.recordingStartedAt) / 1000))
  }
}
