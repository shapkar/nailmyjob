# frozen_string_literal: true

class VoiceSessionsController < ApplicationController
  before_action :require_company!
  before_action :set_voice_session, only: [:show, :process_audio]

  def create
    @voice_session = current_user.voice_sessions.build(voice_session_params)
    @voice_session.status = :recording

    if @voice_session.save
      respond_to do |format|
        format.html { redirect_to @voice_session }
        format.json { render json: { id: @voice_session.id, status: @voice_session.status } }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: dashboard_path, alert: "Failed to create voice session." }
        format.json { render json: { errors: @voice_session.errors }, status: :unprocessable_entity }
      end
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: voice_session_json }
    end
  end

  def process_audio
    # Attach audio file if provided
    if params[:audio_file].present?
      @voice_session.audio_file.attach(params[:audio_file])
    end

    # Process with AI
    VoiceProcessingJob.perform_later(@voice_session.id)

    respond_to do |format|
      format.html { redirect_to @voice_session, notice: "Processing audio..." }
      format.json { render json: { id: @voice_session.id, status: "processing" } }
      format.turbo_stream
    end
  end

  private

  def set_voice_session
    @voice_session = current_user.voice_sessions.find(params[:id])
  end

  def voice_session_params
    params.require(:voice_session).permit(
      :purpose,
      :quote_id,
      :change_order_id,
      :duration_seconds
    )
  end

  def voice_session_json
    {
      id: @voice_session.id,
      status: @voice_session.status,
      transcript: @voice_session.transcript,
      extracted_data: @voice_session.extracted_data,
      confidence_score: @voice_session.confidence_score,
      duration: @voice_session.formatted_duration
    }
  end
end
