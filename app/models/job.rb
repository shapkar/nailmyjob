# frozen_string_literal: true

class Job < ApplicationRecord
  # Associations
  belongs_to :quote
  belongs_to :company
  belongs_to :client
  belongs_to :user
  has_many :change_orders, -> { order(:co_number) }, dependent: :destroy

  # Enums
  enum :status, {
    active: 0,
    on_hold: 1,
    completed: 2,
    cancelled: 3
  }, default: :active

  # Validations
  validates :job_number, presence: true, uniqueness: true
  validates :client_view_token, uniqueness: true, allow_nil: true

  # Callbacks
  before_validation :generate_job_number, on: :create
  before_validation :generate_client_view_token, on: :create
  before_validation :set_initial_values, on: :create

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :active_jobs, -> { where(status: [:active, :on_hold]) }

  # Class Methods
  def self.create_from_quote!(quote)
    raise ArgumentError, "Quote must be signed" unless quote.signed?

    create!(
      quote: quote,
      company: quote.company,
      client: quote.client,
      user: quote.user,
      project_address: quote.project_address,
      project_city: quote.project_city,
      project_state: quote.project_state,
      project_zip_code: quote.project_zip_code,
      contracted_amount_low: quote.total_range_low,
      contracted_amount_high: quote.total_range_high,
      notes: quote.notes
    )
  end

  # Instance Methods
  def project_full_address
    [project_address, project_city, project_state, project_zip_code]
      .compact.reject(&:blank?).join(", ")
  end

  def contracted_range
    "#{format_currency(contracted_amount_low)} – #{format_currency(contracted_amount_high)}"
  end

  def current_total_low
    (contracted_amount_low || 0) + (change_orders_total || 0)
  end

  def current_total_high
    (contracted_amount_high || 0) + (change_orders_total || 0)
  end

  def current_total_range
    "#{format_currency(current_total_low)} – #{format_currency(current_total_high)}"
  end

  def update_change_orders_total!
    update!(change_orders_total: change_orders.signed.sum(:amount))
  end

  def days_active
    return 0 unless start_date

    (Date.current - start_date).to_i
  end

  def progress_status
    return "Not started" unless start_date
    return "Completed" if completed?

    if estimated_completion_date && Date.current > estimated_completion_date
      "Behind schedule"
    else
      "On track"
    end
  end

  private

  def generate_job_number
    return if job_number.present?

    date_part = Time.current.strftime("%y%m")
    sequence = company.jobs.where("job_number LIKE ?", "J#{date_part}%").count + 1
    self.job_number = "J#{date_part}#{sequence.to_s.rjust(4, '0')}"
  end

  def generate_client_view_token
    self.client_view_token ||= SecureRandom.urlsafe_base64(32)
  end

  def set_initial_values
    self.change_orders_total ||= 0
  end

  def format_currency(amount)
    return "$0" if amount.nil? || amount.zero?

    "$#{amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end
end
