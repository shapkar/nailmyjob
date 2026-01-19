import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "newClientFields", "selectedClient"]
  static values = {
    url: { type: String, default: "/clients/search" }
  }

  searchTimeout = null

  connect() {
    // Show new client fields by default
    if (this.hasNewClientFieldsTarget) {
      this.newClientFieldsTarget.classList.remove("hidden")
    }
  }

  async search() {
    const query = this.inputTarget.value.trim()

    // Clear previous timeout
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout)
    }

    // Don't search for less than 2 characters
    if (query.length < 2) {
      this.hideResults()
      return
    }

    // Debounce the search
    this.searchTimeout = setTimeout(async () => {
      try {
        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

        const response = await fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`, {
          headers: {
            "Accept": "application/json",
            "X-CSRF-Token": csrfToken,
            "X-Requested-With": "XMLHttpRequest"
          },
          credentials: "same-origin"
        })

        if (response.ok) {
          const clients = await response.json()
          this.displayResults(clients)
        } else {
          console.error("Client search failed with status:", response.status)
        }
      } catch (error) {
        console.error("Client search failed:", error)
      }
    }, 300)
  }

  displayResults(clients) {
    if (!this.hasResultsTarget) {
      return
    }

    if (clients.length === 0) {
      this.resultsTarget.innerHTML = `
        <div class="px-4 py-3 text-sm text-slate-500">
          No clients found. Enter details below to create a new client.
        </div>
      `
      this.resultsTarget.classList.remove("hidden")

      return
    }

    const html = clients.map(client => `
      <button type="button" 
              class="w-full text-left px-4 py-3 hover:bg-slate-50 transition-colors border-b border-slate-100 last:border-b-0"
              data-action="click->client-search#selectClient"
              data-client-id="${client.id}"
              data-client-name="${client.name}"
              data-client-email="${client.email || ''}">
        <p class="font-medium text-slate-900">${client.name}</p>
        <p class="text-sm text-slate-500">${client.email || 'No email'}</p>
      </button>
    `).join("")

    this.resultsTarget.innerHTML = html
    this.resultsTarget.classList.remove("hidden")
  }

  hideResults() {
    if (this.hasResultsTarget) {
      this.resultsTarget.classList.add("hidden")
    }
  }

  selectClient(event) {
    const button = event.currentTarget
    const clientId = button.dataset.clientId
    const clientName = button.dataset.clientName
    const clientEmail = button.dataset.clientEmail

    // Update hidden field
    const hiddenField = this.element.querySelector("input[name='quote[client_id]']")
    if (hiddenField) {
      hiddenField.value = clientId
    } else {
      // Create hidden field
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "quote[client_id]"
      input.value = clientId
      this.element.appendChild(input)
    }

    // Update input display
    this.inputTarget.value = clientName

    // Hide results and new client fields
    this.hideResults()
    if (this.hasNewClientFieldsTarget) {
      this.newClientFieldsTarget.classList.add("hidden")
    }

    // Show selected client indicator
    if (this.hasSelectedClientTarget) {
      this.selectedClientTarget.textContent = `Selected: ${clientName} (${clientEmail})`
      this.selectedClientTarget.classList.remove("hidden")
    }
  }

  clearSelection() {
    const hiddenField = this.element.querySelector("input[name='quote[client_id]']")
    if (hiddenField) {
      hiddenField.value = ""
    }

    this.inputTarget.value = ""

    if (this.hasNewClientFieldsTarget) {
      this.newClientFieldsTarget.classList.remove("hidden")
    }

    if (this.hasSelectedClientTarget) {
      this.selectedClientTarget.classList.add("hidden")
    }
  }
}
