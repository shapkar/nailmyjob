import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "rangeLow",
    "rangeHigh",
    "rangeHighWrapper",
    "rangeToggle",
    "allowanceToggle",
    "allowanceLabel"
  ]

  connect() {
    this.updateUI()
  }

  toggleRange() {
    this.updateUI()
    
    // If switching from range to fixed, sync values
    if (!this.isRange() && this.hasRangeLowTarget && this.hasRangeHighTarget) {
      this.rangeHighTarget.value = this.rangeLowTarget.value
    }
  }

  toggleAllowance() {
    // When allowance is checked, automatically enable range if not already
    if (this.hasAllowanceToggleTarget && this.allowanceToggleTarget.checked) {
      if (this.hasRangeToggleTarget && !this.rangeToggleTarget.checked) {
        this.rangeToggleTarget.checked = true
        this.updateUI()
      }
    }
    this.updateUI()
  }

  updateUI() {
    const isRange = this.isRange()
    const isAllowance = this.hasAllowanceToggleTarget && this.allowanceToggleTarget.checked

    // Toggle High Price Visibility
    if (this.hasRangeHighWrapperTarget) {
      this.rangeHighWrapperTarget.classList.toggle("hidden", !isRange)
      this.rangeHighWrapperTarget.classList.toggle("flex", isRange)
    }

    // Update Placeholder
    if (this.hasRangeLowTarget) {
      this.rangeLowTarget.placeholder = isRange ? "Low" : "Price"
    }

    // Allowance Label Styling
    if (this.hasAllowanceLabelTarget) {
      this.allowanceLabelTarget.classList.toggle("text-amber-600", isAllowance)
      this.allowanceLabelTarget.classList.toggle("font-bold", isAllowance)
      this.allowanceLabelTarget.classList.toggle("text-stone-500", !isAllowance)
    }
  }

  isRange() {
    return this.hasRangeToggleTarget && this.rangeToggleTarget.checked
  }
}
