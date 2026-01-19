import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["lineItems", "lineItemTemplate", "totalRange", "clientFields", "destroyField"]

  connect() {
    this.updateTotal()
  }

  addLineItem(event) {
    event.preventDefault()

    if (!this.hasLineItemTemplateTarget) return

    const content = this.lineItemTemplateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    // Insert at the top (afterbegin) instead of bottom (beforeend)
    this.lineItemsTarget.insertAdjacentHTML("afterbegin", content)
    
    // Find the newly added item (first child) and highlight it or scroll to it
    const newItem = this.lineItemsTarget.firstElementChild
    if (newItem) {
      newItem.scrollIntoView({ behavior: "smooth", block: "center" })
      // Optional: Add a flash effect class if you have one
    }

    this.updateTotal()
  }

  // Legacy remove method - kept for backward compatibility if needed, 
  // but prefer using nested_form_controller for line items
  removeLineItem(event) {
    event.preventDefault()

    const item = event.target.closest("[data-new-record]")
    if (!item) return

    if (item.dataset.newRecord === "true") {
      item.remove()
    } else {
      // Mark for destruction
      const destroyField = item.querySelector("input[name*='_destroy']")
      if (destroyField) {
        destroyField.value = "1"
      }
      item.style.display = "none"
    }

    this.updateTotal()
  }

  removeClient(event) {
    event.preventDefault()

    const clientIdField = this.element.querySelector("input[name='quote[client_id]']")
    if (clientIdField) {
      clientIdField.value = ""
    }

    // Show client fields again
    if (this.hasClientFieldsTarget) {
      this.clientFieldsTarget.classList.remove("hidden")
    }

    // Remove the client display
    event.target.closest(".flex.items-center.justify-between")?.remove()
  }

  updateTotal() {
    if (!this.hasTotalRangeTarget) return

    let totalLow = 0
    let totalHigh = 0

    // Only select visible line items that are not marked for destruction
    this.element.querySelectorAll("[data-new-record]").forEach((item) => {
      // Check if hidden (style display none) or if _destroy is true
      if (item.style.display === "none") return
      
      const destroyInput = item.querySelector("input[name*='_destroy']")
      if (destroyInput && destroyInput.value === "1") return

      const lowInput = item.querySelector("input[name*='[range_low]']")
      const highInput = item.querySelector("input[name*='[range_high]']")

      if (lowInput && lowInput.value) {
        totalLow += parseFloat(lowInput.value) || 0
      }
      if (highInput && highInput.value) {
        totalHigh += parseFloat(highInput.value) || 0
      }
    })

    this.totalRangeTarget.textContent = `${this.formatCurrency(totalLow)} – ${this.formatCurrency(totalHigh)}`
  }

  formatCurrency(amount) {
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD",
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(amount)
  }
}
