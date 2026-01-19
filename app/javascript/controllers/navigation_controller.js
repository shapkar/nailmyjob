import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "overlay"]

  connect() {
    this.isOpen = false
  }

  toggle() {
    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    if (!this.hasSidebarTarget) {
      return
    }

    this.sidebarTarget.classList.remove("-translate-x-full")
    this.sidebarTarget.classList.add("translate-x-0")

    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.remove("hidden")
    }

    this.isOpen = true
    document.body.classList.add("overflow-hidden")
  }

  close() {
    if (!this.hasSidebarTarget) {
      return
    }

    this.sidebarTarget.classList.add("-translate-x-full")
    this.sidebarTarget.classList.remove("translate-x-0")

    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.add("hidden")
    }

    this.isOpen = false
    document.body.classList.remove("overflow-hidden")
  }
}
