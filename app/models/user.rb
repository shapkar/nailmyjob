# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Virtual attribute for registration
  attr_accessor :company_name

  # Associations
  belongs_to :company, optional: true
  has_many :quotes, dependent: :nullify
  has_many :jobs, dependent: :nullify
  has_many :voice_sessions, dependent: :destroy

  # Enums
  enum :role, { contractor: 0, admin: 1 }, default: :contractor

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true, on: :update
  validates :last_name, presence: true, on: :update
  validates :company_name, presence: true, on: :create

  # Callbacks
  before_create :generate_default_settings
  after_create :create_company_from_name

  # Instance Methods
  def full_name
    [first_name, last_name].compact.join(" ").presence || email.split("@").first
  end

  def initials
    if first_name.present? && last_name.present?
      "#{first_name[0]}#{last_name[0]}".upcase
    else
      email[0..1].upcase
    end
  end

  private

  def generate_default_settings
    self.settings ||= {
      notifications: {
        email_on_quote_viewed: true,
        email_on_quote_signed: true,
        email_on_change_order_signed: true,
        sms_notifications: false
      },
      preferences: {
        default_input_method: "manual",
        auto_save_interval: 30
      }
    }
  end

  def create_company_from_name
    return if company.present? || company_name.blank?

    new_company = Company.create!(name: company_name, email: email)
    update_column(:company_id, new_company.id)
  end
end
