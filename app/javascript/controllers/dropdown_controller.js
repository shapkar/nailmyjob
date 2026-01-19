import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.isOpen = false

    this.boundClickOutside = this.clickOutside.bind(this)
  }

  disconnect() {
    document.removeEventListener("click", this.boundClickOutside)
  }

  toggle(event) {
    event.stopPropagation()

    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    if (!this.hasMenuTarget) {
      return
    }

    this.menuTarget.classList.remove("hidden")
    this.isOpen = true

    document.addEventListener("click", this.boundClickOutside)
  }

  close() {
    if (!this.hasMenuTarget) {
      return
    }

    this.menuTarget.classList.add("hidden")
    this.isOpen = false

    document.removeEventListener("click", this.boundClickOutside)
  }

  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }
}
