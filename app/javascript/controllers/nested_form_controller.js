import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  remove(event) {
    event.preventDefault()

    const wrapper = event.target.closest(".line-item-card") || event.target.closest(".nested-form-wrapper")
    if (!wrapper) return

    // If it's a new record (not saved to DB yet), just remove the DOM element
    if (wrapper.dataset.newRecord === "true") {
      wrapper.remove()
    } else {
      // If it's an existing record, hide it and mark _destroy field
      wrapper.style.display = "none"
      const destroyInput = wrapper.querySelector("input[name*='_destroy']")
      if (destroyInput) {
        destroyInput.value = "1"
      }
    }

    // Optional: Trigger an event to recalculate totals if needed
    // The quote-form controller listens for input changes, so this might need explicit trigger
    const inputEvent = new Event("input", { bubbles: true })
    this.element.dispatchEvent(inputEvent)
  }
}
