import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  selectVoice() {
    // Navigate to voice capture flow
    // In a full implementation, this would open a modal or navigate to a voice capture page
    window.location.href = "/voice_sessions/new?purpose=quote_creation"
  }
}
