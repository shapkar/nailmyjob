import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["notification"]

  connect() {
    // Auto-dismiss after 5 seconds
    this.autoDismissTimeout = setTimeout(() => {
      this.dismiss()
    }, 5000)

    // Animate in
    this.element.style.opacity = "0"
    this.element.style.transform = "translateX(100%)"

    requestAnimationFrame(() => {
      this.element.style.transition = "all 0.3s ease-out"
      this.element.style.opacity = "1"
      this.element.style.transform = "translateX(0)"
    })
  }

  disconnect() {
    if (this.autoDismissTimeout) {
      clearTimeout(this.autoDismissTimeout)
    }
  }

  dismiss() {
    // Animate out
    this.element.style.transition = "all 0.3s ease-in"
    this.element.style.opacity = "0"
    this.element.style.transform = "translateX(100%)"

    // Remove after animation
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }

  remove() {
    this.element.remove()
  }
}
