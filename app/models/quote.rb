# frozen_string_literal: true

class Quote < ApplicationRecord
  # Attachments
  has_one_attached :pdf

  # Associations
  belongs_to :company
  belongs_to :user
  belongs_to :client, optional: true
  has_many :line_items, -> { order(:sort_order) }, dependent: :destroy
  has_one :job, dependent: :nullify
  has_many :voice_sessions, dependent: :nullify

  # Nested attributes
  accepts_nested_attributes_for :line_items, allow_destroy: true
  accepts_nested_attributes_for :client

  # Enums - Quote statuses only (no job statuses)
  enum :status, {
    draft: 0,
    sent: 1,
    viewed: 2,
    accepted: 3,  # Quote is accepted/signed, Job gets created
    rejected: 6,
    expired: 7
  }, default: :draft

  enum :template_type, {
    kitchen: 0,
    bathroom: 1,
    custom: 2
  }, default: :kitchen

  enum :project_size, {
    small: 0,
    medium: 1,
    large: 2
  }, default: :medium

  # Validations
  validates :quote_number, presence: true, uniqueness: true
  validates :client_view_token, uniqueness: true, allow_nil: true
  validates :valid_days, numericality: { greater_than: 0 }, allow_nil: true

  # Callbacks
  before_validation :generate_quote_number, on: :create
  before_validation :generate_client_view_token, on: :create
  before_save :calculate_totals
  after_update :create_job_if_accepted, if: -> { saved_change_to_status? && accepted? }

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :active, -> { where(status: [:draft, :sent, :viewed]) }
  scope :needs_attention, -> { where(status: [:sent, :viewed]) }
  scope :without_job, -> { left_joins(:job).where(jobs: { id: nil }) }
  scope :with_job, -> { joins(:job) }

  # Instance Methods
  def project_full_address
    [project_address, project_city, project_state, project_zip_code]
      .compact.reject(&:blank?).join(", ")
  end

  def total_range
    "#{format_currency(total_range_low)} – #{format_currency(total_range_high)}"
  end

  # For backward compatibility - redirect to job if exists
  def current_total_low
    return job.current_total_low if job.present?

    total_range_low || 0
  end

  def current_total_high
    return job.current_total_high if job.present?

    total_range_high || 0
  end

  def current_total_range
    return job.current_total_range if job.present?

    total_range
  end

  def signed?
    signed_at.present? && signature_data.present?
  end

  def has_job?
    job.present?
  end

  def expired?
    return false if valid_days.blank? || created_at.blank?
    return false if accepted? || signed?

    created_at + valid_days.days < Time.current
  end

  def days_until_expiry
    return nil if valid_days.blank? || created_at.blank?

    (created_at + valid_days.days - Time.current).to_i / 1.day
  end

  def mark_as_viewed!
    update!(viewed_at: Time.current, status: :viewed) if sent?
  end

  def mark_as_sent!
    if draft?
      update!(sent_at: Time.current, status: :sent)
    else
      update!(sent_at: Time.current)
    end
  end

  def sign!(signature_data:, signer_ip: nil, signer_geolocation: nil)
    update!(
      signed_at: Time.current,
      status: :accepted,
      signature_data: {
        signature_image: signature_data,
        signed_at: Time.current.iso8601,
        ip_address: signer_ip,
        geolocation: signer_geolocation
      }
    )
  end

  def allowance_items
    line_items.where(is_allowance: true)
  end

  def labor_items
    line_items.where(category: [:demo, :electrical, :plumbing, :labor, :permits])
  end

  def material_items
    line_items.where(category: [:cabinets, :countertops, :flooring, :backsplash, :appliances])
  end

  def duplicate!
    new_quote = dup
    new_quote.quote_number = nil
    new_quote.client_view_token = nil
    new_quote.status = :draft
    new_quote.sent_at = nil
    new_quote.viewed_at = nil
    new_quote.accepted_at = nil
    new_quote.signed_at = nil
    new_quote.signature_data = nil

    line_items.each do |item|
      new_quote.line_items.build(item.attributes.except("id", "quote_id", "created_at", "updated_at"))
    end

    new_quote.save!
    new_quote
  end

  # Backward compatibility - change orders now belong to jobs
  def change_orders
    return job.change_orders if job.present?

    ChangeOrder.none
  end

  def approved_changes_total
    return job.change_orders_total if job.present?

    0
  end

  private

  def generate_quote_number
    return if quote_number.present?

    prefix = template_type.to_s[0].upcase
    date_part = Time.current.strftime("%y%m")
    sequence = company.quotes.where("quote_number LIKE ?", "#{prefix}#{date_part}%").count + 1
    self.quote_number = "#{prefix}#{date_part}#{sequence.to_s.rjust(4, '0')}"
  end

  def generate_client_view_token
    self.client_view_token ||= SecureRandom.urlsafe_base64(32)
  end

  def calculate_totals
    self.total_range_low = line_items.sum { |item| item.range_low || 0 }
    self.total_range_high = line_items.sum { |item| item.range_high || 0 }
  end

  def create_job_if_accepted
    return if job.present?

    Job.create_from_quote!(self)
  end

  def format_currency(amount)
    return "$0" if amount.nil? || amount.zero?

    "$#{amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end
end
