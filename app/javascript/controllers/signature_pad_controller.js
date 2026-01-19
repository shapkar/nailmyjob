import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas", "input", "clearButton", "submitButton"]

  connect() {
    this.setupCanvas()
    this.isDrawing = false
    this.lastX = 0
    this.lastY = 0
    this.hasSignature = false
  }

  setupCanvas() {
    if (!this.hasCanvasTarget) {
      return
    }

    const canvas = this.canvasTarget
    const rect = canvas.getBoundingClientRect()

    canvas.width = rect.width * window.devicePixelRatio
    canvas.height = rect.height * window.devicePixelRatio

    this.ctx = canvas.getContext("2d")
    this.ctx.scale(window.devicePixelRatio, window.devicePixelRatio)

    this.ctx.strokeStyle = "#1e293b"
    this.ctx.lineWidth = 2
    this.ctx.lineCap = "round"
    this.ctx.lineJoin = "round"

    this.addEventListeners()
  }

  addEventListeners() {
    const canvas = this.canvasTarget

    canvas.addEventListener("mousedown", this.startDrawing.bind(this))
    canvas.addEventListener("mousemove", this.draw.bind(this))
    canvas.addEventListener("mouseup", this.stopDrawing.bind(this))
    canvas.addEventListener("mouseout", this.stopDrawing.bind(this))

    canvas.addEventListener("touchstart", this.handleTouchStart.bind(this), { passive: false })
    canvas.addEventListener("touchmove", this.handleTouchMove.bind(this), { passive: false })
    canvas.addEventListener("touchend", this.stopDrawing.bind(this))
  }

  getCoordinates(event) {
    const canvas = this.canvasTarget
    const rect = canvas.getBoundingClientRect()

    if (event.touches) {
      return {
        x: event.touches[0].clientX - rect.left,
        y: event.touches[0].clientY - rect.top
      }
    }

    return {
      x: event.clientX - rect.left,
      y: event.clientY - rect.top
    }
  }

  startDrawing(event) {
    this.isDrawing = true

    const coords = this.getCoordinates(event)

    this.lastX = coords.x
    this.lastY = coords.y

    this.canvasTarget.classList.add("signing")
  }

  draw(event) {
    if (!this.isDrawing) {
      return
    }

    event.preventDefault()

    const coords = this.getCoordinates(event)

    this.ctx.beginPath()
    this.ctx.moveTo(this.lastX, this.lastY)
    this.ctx.lineTo(coords.x, coords.y)
    this.ctx.stroke()

    this.lastX = coords.x
    this.lastY = coords.y
    this.hasSignature = true

    this.updateButtons()
  }

  stopDrawing() {
    this.isDrawing = false

    this.canvasTarget.classList.remove("signing")

    if (this.hasSignature) {
      this.updateSignatureData()
    }
  }

  handleTouchStart(event) {
    event.preventDefault()

    this.startDrawing(event)
  }

  handleTouchMove(event) {
    event.preventDefault()

    this.draw(event)
  }

  clear() {
    const canvas = this.canvasTarget
    const rect = canvas.getBoundingClientRect()

    this.ctx.clearRect(0, 0, rect.width, rect.height)

    this.hasSignature = false

    this.updateButtons()
    this.updateSignatureData()
  }

  updateButtons() {
    if (this.hasClearButtonTarget) {
      this.clearButtonTarget.disabled = !this.hasSignature
    }

    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = !this.hasSignature
    }
  }

  updateSignatureData() {
    if (!this.hasInputTarget) {
      return
    }

    if (this.hasSignature) {
      const dataUrl = this.canvasTarget.toDataURL("image/png")

      this.inputTarget.value = dataUrl
    } else {
      this.inputTarget.value = ""
    }
  }

  isBlank() {
    return !this.hasSignature
  }
}
