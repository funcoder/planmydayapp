import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="brain-dump"
export default class extends Controller {
  static targets = ["input", "voiceButton", "charCount", "submitButton", "form"]
  static values = { 
    maxLength: { type: Number, default: 500 },
    recording: { type: Boolean, default: false }
  }

  connect() {
    this.updateCharCount()
    this.checkSpeechRecognition()
  }

  updateCharCount() {
    if (!this.hasInputTarget || !this.hasCharCountTarget) return
    
    const remaining = this.maxLengthValue - this.inputTarget.value.length
    this.charCountTarget.textContent = `${remaining} characters remaining`
    
    if (remaining < 50) {
      this.charCountTarget.classList.add("text-red-600")
    } else {
      this.charCountTarget.classList.remove("text-red-600")
    }
  }

  checkSpeechRecognition() {
    if (!this.hasVoiceButtonTarget) return
    
    if (!('webkitSpeechRecognition' in window) && !('SpeechRecognition' in window)) {
      this.voiceButtonTarget.style.display = 'none'
    }
  }

  toggleVoiceInput() {
    if (this.recordingValue) {
      this.stopRecording()
    } else {
      this.startRecording()
    }
  }

  startRecording() {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition
    this.recognition = new SpeechRecognition()
    
    this.recognition.continuous = true
    this.recognition.interimResults = true
    this.recognition.lang = 'en-US'

    this.recognition.onstart = () => {
      this.recordingValue = true
      this.voiceButtonTarget.classList.add("animate-pulse", "text-red-600")
      this.voiceButtonTarget.textContent = "🔴 Recording..."
    }

    this.recognition.onresult = (event) => {
      let finalTranscript = ''
      let interimTranscript = ''

      for (let i = event.resultIndex; i < event.results.length; i++) {
        const transcript = event.results[i][0].transcript
        if (event.results[i].isFinal) {
          finalTranscript += transcript + ' '
        } else {
          interimTranscript += transcript
        }
      }

      if (finalTranscript) {
        // Process the transcript for better formatting
        let processedText = this.formatTranscript(finalTranscript)
        
        // Add to existing text or start new sentence
        if (this.inputTarget.value.length === 0) {
          this.inputTarget.value = processedText
        } else {
          // Add space if needed
          const lastChar = this.inputTarget.value.slice(-1)
          if (lastChar !== ' ' && lastChar !== '.' && lastChar !== '!' && lastChar !== '?') {
            this.inputTarget.value += ' '
          }
          this.inputTarget.value += processedText
        }
        
        this.updateCharCount()
      }
    }

    this.recognition.onerror = (event) => {
      console.error('Speech recognition error:', event.error)
      this.stopRecording()
    }

    this.recognition.start()
  }

  stopRecording() {
    if (this.recognition) {
      this.recognition.stop()
      this.recordingValue = false
      this.voiceButtonTarget.classList.remove("animate-pulse", "text-red-600")
      this.voiceButtonTarget.textContent = "🎤 Voice Input"
    }
  }

  formatTranscript(text) {
    // Trim whitespace
    text = text.trim()
    
    // Capitalize first letter
    if (text.length > 0) {
      text = text.charAt(0).toUpperCase() + text.slice(1)
    }
    
    // Add period at the end if no punctuation
    const lastChar = text.slice(-1)
    if (lastChar !== '.' && lastChar !== '!' && lastChar !== '?' && lastChar !== ',') {
      text += '.'
    }
    
    // Capitalize after periods
    text = text.replace(/\. ([a-z])/g, (match, letter) => '. ' + letter.toUpperCase())
    
    // Common corrections
    text = text.replace(/\bi\b/g, 'I') // Capitalize "I"
    text = text.replace(/\bi'm\b/gi, "I'm")
    text = text.replace(/\bi've\b/gi, "I've")
    text = text.replace(/\bi'll\b/gi, "I'll")
    text = text.replace(/\bi'd\b/gi, "I'd")
    
    return text
  }

  clear() {
    if (confirm("Are you sure you want to clear your brain dump?")) {
      this.inputTarget.value = ""
      this.updateCharCount()
      this.inputTarget.focus()
    }
  }

  // Handle form submission success - Turbo will handle the actual submission
  handleSuccess(event) {
    // Clear the input after successful submission
    this.inputTarget.value = ""
    this.updateCharCount()

    // Remove the "no brain dumps" message if it exists
    const noBrainDumps = document.getElementById('no_brain_dumps')
    if (noBrainDumps) {
      noBrainDumps.remove()
    }

    // Keep focus on input for continuous entry
    setTimeout(() => {
      this.inputTarget.focus()
    }, 100)
  }
}