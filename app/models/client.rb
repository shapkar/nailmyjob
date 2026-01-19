# frozen_string_literal: true

class Client < ApplicationRecord
  # Associations
  belongs_to :company
  has_many :quotes, dependent: :nullify
  has_many :jobs, dependent: :nullify

  # Validations
  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :magic_link_token, uniqueness: true, allow_nil: true

  # Callbacks
  before_create :generate_magic_link_token

  # Scopes
  scope :search, ->(query) {
    where("name ILIKE :q OR email ILIKE :q OR phone ILIKE :q", q: "%#{query}%")
  }
  scope :recent, -> { order(created_at: :desc) }

  # Instance Methods
  def full_address
    [address, city, state, zip_code].compact.reject(&:blank?).join(", ")
  end

  def formatted_phone
    return nil unless phone.present?

    Phonelib.parse(phone, "US").national
  end

  def regenerate_magic_link!
    update!(
      magic_link_token: SecureRandom.urlsafe_base64(32),
      magic_link_expires_at: 30.days.from_now
    )
  end

  def magic_link_valid?
    magic_link_token.present? && magic_link_expires_at&.future?
  end

  private

  def generate_magic_link_token
    self.magic_link_token ||= SecureRandom.urlsafe_base64(32)
    self.magic_link_expires_at ||= 30.days.from_now
  end
end
