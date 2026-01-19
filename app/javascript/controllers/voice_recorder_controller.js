import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "status", "timer", "waveform"]
  static values = {
    sessionUrl: String,
    maxDuration: { type: Number, default: 300 }
  }

  connect() {
    this.isRecording = false
    this.mediaRecorder = null
    this.audioChunks = []
    this.startTime = null
    this.timerInterval = null
  }

  disconnect() {
    this.stopRecording()
  }

  async toggleRecording() {
    if (this.isRecording) {
      await this.stopRecording()
    } else {
      await this.startRecording()
    }
  }

  async startRecording() {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true })

      this.mediaRecorder = new MediaRecorder(stream, {
        mimeType: this.getSupportedMimeType()
      })

      this.audioChunks = []

      this.mediaRecorder.addEventListener("dataavailable", (event) => {
        if (event.data.size > 0) {
          this.audioChunks.push(event.data)
        }
      })

      this.mediaRecorder.addEventListener("stop", () => {
        this.handleRecordingComplete()
      })

      this.mediaRecorder.start(1000)
      this.isRecording = true
      this.startTime = Date.now()

      this.updateUI()
      this.startTimer()
    } catch (error) {
      console.error("Error starting recording:", error)
      this.showError("Could not access microphone. Please check permissions.")
    }
  }

  async stopRecording() {
    if (!this.mediaRecorder) {
      return
    }

    this.mediaRecorder.stop()
    this.mediaRecorder.stream.getTracks().forEach(track => track.stop())

    this.isRecording = false
    this.stopTimer()

    this.updateUI()
  }

  handleRecordingComplete() {
    const audioBlob = new Blob(this.audioChunks, {
      type: this.getSupportedMimeType()
    })

    const duration = Math.round((Date.now() - this.startTime) / 1000)

    this.dispatch("complete", {
      detail: {
        blob: audioBlob,
        duration: duration
      }
    })
  }

  startTimer() {
    this.timerInterval = setInterval(() => {
      const elapsed = Math.round((Date.now() - this.startTime) / 1000)

      this.updateTimerDisplay(elapsed)

      if (elapsed >= this.maxDurationValue) {
        this.stopRecording()
      }
    }, 1000)
  }

  stopTimer() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
      this.timerInterval = null
    }
  }

  updateTimerDisplay(seconds) {
    if (!this.hasTimerTarget) {
      return
    }

    const minutes = Math.floor(seconds / 60)
    const secs = seconds % 60

    this.timerTarget.textContent = `${minutes}:${secs.toString().padStart(2, "0")}`
  }

  updateUI() {
    if (this.hasButtonTarget) {
      if (this.isRecording) {
        this.buttonTarget.classList.add("recording-pulse", "bg-red-500")
        this.buttonTarget.classList.remove("bg-emerald-500")
      } else {
        this.buttonTarget.classList.remove("recording-pulse", "bg-red-500")
        this.buttonTarget.classList.add("bg-emerald-500")
      }
    }

    if (this.hasStatusTarget) {
      this.statusTarget.textContent = this.isRecording ? "Recording..." : "Tap to start"
    }
  }

  showError(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
      this.statusTarget.classList.add("text-red-500")
    }
  }

  getSupportedMimeType() {
    const mimeTypes = [
      "audio/webm;codecs=opus",
      "audio/webm",
      "audio/mp4",
      "audio/ogg;codecs=opus",
      "audio/wav"
    ]

    for (const mimeType of mimeTypes) {
      if (MediaRecorder.isTypeSupported(mimeType)) {
        return mimeType
      }
    }

    return "audio/webm"
  }
}
