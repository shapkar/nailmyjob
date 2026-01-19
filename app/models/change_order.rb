# frozen_string_literal: true

class ChangeOrder < ApplicationRecord
  # Attachments
  has_one_attached :pdf

  # Associations
  belongs_to :job
  belongs_to :quote, optional: true  # Keep for historical reference
  belongs_to :line_item, optional: true
  has_many :voice_sessions, dependent: :nullify

  # Enums
  enum :status, {
    draft: 0,
    sent: 1,
    viewed: 2,
    signed: 3,
    rejected: 4
  }, default: :draft

  enum :category, {
    cabinets: 0,
    countertops: 1,
    flooring: 2,
    backsplash: 3,
    appliances: 4,
    plumbing: 5,
    electrical: 6,
    demo: 7,
    labor: 8,
    permits: 9,
    other: 10
  }, default: :other

  # Validations
  validates :description, presence: true
  validates :amount, presence: true, numericality: true
  validates :co_number, presence: true, uniqueness: { scope: :job_id }
  validates :client_view_token, uniqueness: true, allow_nil: true

  # Callbacks
  before_validation :set_co_number, on: :create
  before_validation :generate_client_view_token, on: :create
  before_validation :set_legal_boilerplate, on: :create
  after_save :update_job_change_orders_total, if: :signed?

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :pending_signature, -> { where(status: [:sent, :viewed]) }
  scope :signed, -> { where(status: :signed) }

  # Delegations for convenience
  delegate :client, :company, :user, to: :job
  delegate :quote, to: :job, prefix: :original, allow_nil: true

  # Instance Methods
  def signed?
    status == "signed" && signature_data.present?
  end

  def mark_as_viewed!
    update!(status: :viewed) if sent?
  end

  def mark_as_sent!
    update!(sent_at: Time.current, status: :sent) if draft?
  end

  def sign!(signature_data:, signer_name:, signer_email: nil, signer_ip: nil, signer_geolocation: nil)
    update!(
      status: :signed,
      signed_at: Time.current,
      signer_name: signer_name,
      signer_email: signer_email,
      signer_ip_address: signer_ip,
      signer_geolocation: signer_geolocation,
      signature_data: {
        signature_image: signature_data,
        signed_at: Time.current.iso8601,
        ip_address: signer_ip,
        geolocation: signer_geolocation,
        signer_name: signer_name,
        signer_email: signer_email
      }
    )
  end

  def formatted_amount
    return "$0" if amount.nil? || amount.zero?

    sign = amount.negative? ? "-" : "+"
    "#{sign}$#{amount.abs.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end

  def schedule_impact_display
    return "No delay" unless delays_schedule

    delay_days.present? ? "Delays by #{delay_days} days" : "Delays schedule"
  end

  def new_total_low
    job.current_total_low + (signed? ? 0 : amount)
  end

  def new_total_high
    job.current_total_high + (signed? ? 0 : amount)
  end

  def category_icon
    LineItem.category_icon(category)
  end

  private

  def set_co_number
    return if co_number.present?

    max_number = job.change_orders.maximum(:co_number) || 0
    self.co_number = max_number + 1
  end

  def generate_client_view_token
    self.client_view_token ||= SecureRandom.urlsafe_base64(32)
  end

  def set_legal_boilerplate
    return if legal_boilerplate.present?

    self.legal_boilerplate = job.company.legal_boilerplate
  end

  def update_job_change_orders_total
    job.update_change_orders_total!
  end
end
