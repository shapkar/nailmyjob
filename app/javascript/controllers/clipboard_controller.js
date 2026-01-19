import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    text: String
  }

  async copy() {
    const text = this.textValue || this.element.dataset.clipboardText

    if (!text) {
      return
    }

    try {
      await navigator.clipboard.writeText(text)

      this.showFeedback("Copied!")
    } catch (error) {
      console.error("Failed to copy:", error)

      this.showFeedback("Failed to copy")
    }
  }

  showFeedback(message) {
    const originalText = this.element.textContent

    this.element.textContent = message
    this.element.disabled = true

    setTimeout(() => {
      this.element.textContent = originalText
      this.element.disabled = false
    }, 2000)
  }
}
