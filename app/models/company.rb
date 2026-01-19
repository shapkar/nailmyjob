# frozen_string_literal: true

class Company < ApplicationRecord
  # Attachments
  has_one_attached :logo

  # Associations
  has_many :users, dependent: :nullify
  has_many :clients, dependent: :destroy
  has_many :quotes, dependent: :destroy
  has_many :jobs, dependent: :destroy
  has_many :quote_templates, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  # Callbacks
  before_create :set_default_markups
  before_create :set_default_terms

  # Constants
  DEFAULT_LABOR_MARKUP = 30.0
  DEFAULT_MATERIAL_MARKUP = 20.0

  DEFAULT_TERMS = <<~TERMS
    This estimate is valid for 30 days from the date of issue.
    A 30% deposit is required to schedule the project.
    Progress payments will be due at key milestones.
    Final 10% payment due upon satisfactory completion.
  TERMS

  DEFAULT_PAYMENT_TERMS = <<~PAYMENT
    - 30% deposit to schedule project
    - Progress payments at milestones
    - 10% upon satisfactory completion
  PAYMENT

  DEFAULT_LEGAL_BOILERPLATE = <<~LEGAL
    I authorize this change to the original project scope and agree to the additional cost stated above.
    This change order becomes part of the original contract and is subject to all original terms and conditions.
  LEGAL

  # Instance Methods
  def logo_url
    return nil unless logo.attached?

    Rails.application.routes.url_helpers.rails_blob_url(logo, only_path: true)
  end

  def formatted_phone
    return nil unless phone.present?

    Phonelib.parse(phone, "US").national
  end

  def full_address
    [address, city, state, zip_code].compact.reject(&:blank?).join(", ")
  end

  private

  def set_default_markups
    self.default_labor_markup ||= DEFAULT_LABOR_MARKUP
    self.default_material_markup ||= DEFAULT_MATERIAL_MARKUP
  end

  def set_default_terms
    self.default_terms ||= DEFAULT_TERMS.strip
    self.default_payment_terms ||= DEFAULT_PAYMENT_TERMS.strip
    self.legal_boilerplate ||= DEFAULT_LEGAL_BOILERPLATE.strip
  end
end
