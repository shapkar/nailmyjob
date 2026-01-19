# frozen_string_literal: true

class VoiceSession < ApplicationRecord
  # Attachments
  has_one_attached :audio_file

  # Associations
  belongs_to :user
  belongs_to :quote, optional: true
  belongs_to :change_order, optional: true

  # Enums
  enum :purpose, {
    quote_creation: 0,
    change_order: 1,
    line_item_update: 2
  }, default: :quote_creation

  enum :status, {
    recording: 0,
    processing: 1,
    completed: 2,
    failed: 3
  }, default: :recording

  # Validations
  validates :purpose, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :completed, -> { where(status: :completed) }
  scope :failed, -> { where(status: :failed) }

  # Instance Methods
  def extracted_client_name
    extracted_data&.dig("client_name")
  end

  def extracted_address
    extracted_data&.dig("project_address")
  end

  def extracted_project_size
    extracted_data&.dig("project_size")
  end

  def extracted_template_type
    extracted_data&.dig("template_type")
  end

  def extracted_line_items
    extracted_data&.dig("line_items") || []
  end

  def extraction_confidence
    return nil unless confidence_score

    if confidence_score >= 0.85
      :high
    elsif confidence_score >= 0.60
      :medium
    else
      :low
    end
  end

  def confidence_color
    {
      high: "green",
      medium: "yellow",
      low: "red"
    }[extraction_confidence] || "gray"
  end

  def formatted_duration
    return nil unless duration_seconds

    minutes = duration_seconds / 60
    seconds = duration_seconds % 60

    if minutes.positive?
      "#{minutes}m #{seconds}s"
    else
      "#{seconds}s"
    end
  end

  def mark_as_processing!
    update!(status: :processing)
  end

  def complete!(transcript:, extracted_data:, confidence_score:)
    update!(
      status: :completed,
      transcript: transcript,
      extracted_data: extracted_data,
      confidence_score: confidence_score
    )
  end

  def fail!(error_message = nil)
    update!(
      status: :failed,
      extracted_data: { error: error_message }
    )
  end
end
