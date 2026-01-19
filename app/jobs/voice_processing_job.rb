# frozen_string_literal: true

class VoiceProcessingJob < ApplicationJob
  queue_as :default

  def perform(voice_session_id)
    voice_session = VoiceSession.find(voice_session_id)
    voice_session.mark_as_processing!

    # Step 1: Transcribe audio
    unless voice_session.transcript.present?
      transcription_result = VoiceTranscriptionService.new(voice_session.audio_file).transcribe

      unless transcription_result[:success]
        voice_session.fail!(transcription_result[:error])
        return
      end

      voice_session.update!(transcript: transcription_result[:transcript])
    end

    # Step 2: Extract structured data
    extraction_result = VoiceExtractionService.new(voice_session.transcript).extract

    unless extraction_result[:success]
      voice_session.fail!(extraction_result[:error])
      return
    end

    # Step 3: Complete session
    voice_session.complete!(
      transcript: voice_session.transcript,
      extracted_data: extraction_result[:extracted_data],
      confidence_score: extraction_result[:confidence_score]
    )

    # Broadcast update via Turbo Stream
    broadcast_update(voice_session)
  rescue StandardError => e
    Rails.logger.error("VoiceProcessingJob error: #{e.message}")
    voice_session&.fail!(e.message)
  end

  private

  def broadcast_update(voice_session)
    Turbo::StreamsChannel.broadcast_replace_to(
      "voice_session_#{voice_session.id}",
      target: "voice_session_#{voice_session.id}",
      partial: "voice_sessions/voice_session",
      locals: { voice_session: voice_session }
    )
  end
end
