import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["delayFields", "tmFields"]

  connect() {
    // Initial state is set via class
  }

  toggleDelay(event) {
    if (this.hasDelayFieldsTarget) {
      if (event.target.checked) {
        this.delayFieldsTarget.classList.remove("hidden")
      } else {
        this.delayFieldsTarget.classList.add("hidden")
      }
    }
  }

  toggleTM(event) {
    if (this.hasTmFieldsTarget) {
      if (event.target.checked) {
        this.tmFieldsTarget.classList.remove("hidden")
      } else {
        this.tmFieldsTarget.classList.add("hidden")
      }
    }
  }
}
