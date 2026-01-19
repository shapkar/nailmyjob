import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas", "data", "form", "submit", "geolocation"]

  ctx = null
  isDrawing = false
  lastX = 0
  lastY = 0
  hasSignature = false

  connect() {
    this.setupCanvas()
    this.requestGeolocation()
  }

  setupCanvas() {
    if (!this.hasCanvasTarget) return

    const canvas = this.canvasTarget
    this.ctx = canvas.getContext("2d")

    // Set canvas size to match display size
    this.resizeCanvas()
    window.addEventListener("resize", () => this.resizeCanvas())

    // Drawing events
    canvas.addEventListener("mousedown", this.startDrawing.bind(this))
    canvas.addEventListener("mousemove", this.draw.bind(this))
    canvas.addEventListener("mouseup", this.stopDrawing.bind(this))
    canvas.addEventListener("mouseout", this.stopDrawing.bind(this))

    // Touch events for mobile
    canvas.addEventListener("touchstart", this.handleTouchStart.bind(this), { passive: false })
    canvas.addEventListener("touchmove", this.handleTouchMove.bind(this), { passive: false })
    canvas.addEventListener("touchend", this.stopDrawing.bind(this))

    // Style
    this.ctx.strokeStyle = "#1e293b"
    this.ctx.lineWidth = 2
    this.ctx.lineCap = "round"
    this.ctx.lineJoin = "round"
  }

  resizeCanvas() {
    if (!this.hasCanvasTarget) return

    const canvas = this.canvasTarget
    const rect = canvas.getBoundingClientRect()

    canvas.width = rect.width
    canvas.height = rect.height

    // Re-apply style after resize
    if (this.ctx) {
      this.ctx.strokeStyle = "#1e293b"
      this.ctx.lineWidth = 2
      this.ctx.lineCap = "round"
      this.ctx.lineJoin = "round"
    }
  }

  startDrawing(event) {
    this.isDrawing = true
    const { offsetX, offsetY } = event
    this.lastX = offsetX
    this.lastY = offsetY
  }

  draw(event) {
    if (!this.isDrawing || !this.ctx) return

    event.preventDefault()

    const { offsetX, offsetY } = event

    this.ctx.beginPath()
    this.ctx.moveTo(this.lastX, this.lastY)
    this.ctx.lineTo(offsetX, offsetY)
    this.ctx.stroke()

    this.lastX = offsetX
    this.lastY = offsetY
    this.hasSignature = true
  }

  stopDrawing() {
    this.isDrawing = false
  }

  handleTouchStart(event) {
    event.preventDefault()
    const touch = event.touches[0]
    const rect = this.canvasTarget.getBoundingClientRect()

    this.isDrawing = true
    this.lastX = touch.clientX - rect.left
    this.lastY = touch.clientY - rect.top
  }

  handleTouchMove(event) {
    if (!this.isDrawing || !this.ctx) return

    event.preventDefault()
    const touch = event.touches[0]
    const rect = this.canvasTarget.getBoundingClientRect()

    const x = touch.clientX - rect.left
    const y = touch.clientY - rect.top

    this.ctx.beginPath()
    this.ctx.moveTo(this.lastX, this.lastY)
    this.ctx.lineTo(x, y)
    this.ctx.stroke()

    this.lastX = x
    this.lastY = y
    this.hasSignature = true
  }

  clear() {
    if (!this.ctx || !this.hasCanvasTarget) return

    this.ctx.clearRect(0, 0, this.canvasTarget.width, this.canvasTarget.height)
    this.hasSignature = false
  }

  prepareSubmit(event) {
    if (!this.hasSignature) {
      event.preventDefault()
      alert("Please provide your signature before submitting.")
      return false
    }

    // Convert signature to data URL
    if (this.hasDataTarget && this.hasCanvasTarget) {
      this.dataTarget.value = this.canvasTarget.toDataURL("image/png")
    }

    return true
  }

  requestGeolocation() {
    if (!this.hasGeolocationTarget) return

    if ("geolocation" in navigator) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          this.geolocationTarget.value = JSON.stringify({
            latitude: position.coords.latitude,
            longitude: position.coords.longitude,
            accuracy: position.coords.accuracy
          })
        },
        (error) => {
          console.log("Geolocation not available:", error.message)
        }
      )
    }
  }
}
