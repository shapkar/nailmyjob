# frozen_string_literal: true

class LineItem < ApplicationRecord
  # Associations
  belongs_to :quote
  has_many :change_orders, dependent: :nullify

  # Enums
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

  enum :quality_tier, {
    good: 0,
    better: 1,
    best: 2
  }, default: :better

  enum :selection_status, {
    pending: 0,
    finalized: 1
  }, default: :pending

  # Validations
  validates :description, presence: true
  validates :range_low, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :range_high, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :range_low_less_than_high, if: :is_range?
  validate :has_price

  # Callbacks
  before_save :set_default_sort_order
  before_save :sync_range_values
  after_save :recalculate_quote_totals

  # Scopes
  scope :allowances, -> { where(is_allowance: true) }
  scope :fixed, -> { where(is_allowance: false) }
  scope :materials, -> { where(category: [:cabinets, :countertops, :flooring, :backsplash, :appliances]) }
  scope :labor, -> { where(category: [:demo, :electrical, :plumbing, :labor, :permits]) }

  # Class Methods
  def self.category_icon(category)
    {
      cabinets: "🗄️",
      countertops: "🔲",
      flooring: "▤",
      backsplash: "◫",
      appliances: "🔌",
      plumbing: "🔧",
      electrical: "⚡",
      demo: "🔨",
      labor: "👷",
      permits: "📋",
      other: "📦"
    }[category.to_sym] || "📦"
  end

  # Instance Methods
  def range_display
    return format_currency(price) unless is_range?

    "#{format_currency(range_low)} – #{format_currency(range_high)}"
  end

  # Single price accessor (uses range_low as the single price)
  def price
    range_low
  end

  def price=(value)
    self.range_low = value
    self.range_high = value unless is_range?
  end

  def suggested_range_display
    return nil unless suggested_range_low && suggested_range_high

    "#{format_currency(suggested_range_low)} – #{format_currency(suggested_range_high)}"
  end

  def icon
    self.class.category_icon(category)
  end

  def material?
    %w[cabinets countertops flooring backsplash appliances].include?(category)
  end

  def labor?
    %w[demo electrical plumbing labor permits].include?(category)
  end

  def overbudget?
    return false unless final_price && is_allowance

    final_price > range_high
  end

  def overage_amount
    return 0 unless overbudget?

    final_price - range_high
  end

  def within_range?
    return true unless final_price && is_allowance

    final_price >= range_low && final_price <= range_high
  end

  def budget_status
    return :pending unless final_price && is_allowance

    if final_price <= range_low
      :under
    elsif final_price <= range_high
      :within
    else
      :over
    end
  end

  def budget_status_color
    {
      pending: "gray",
      under: "green",
      within: "green",
      over: "red"
    }[budget_status]
  end

  private

  def range_low_less_than_high
    return unless range_low && range_high && range_low > range_high

    errors.add(:range_low, "must be less than or equal to range high")
  end

  def has_price
    return if range_low.present? || range_high.present?

    errors.add(:range_low, "price is required")
  end

  def sync_range_values
    # For non-range items, ensure range_high equals range_low
    unless is_range?
      self.range_high = range_low if range_low.present?
    end
  end

  def set_default_sort_order
    return if sort_order.present?

    max_order = quote.line_items.maximum(:sort_order) || 0
    self.sort_order = max_order + 1
  end

  def recalculate_quote_totals
    quote.save! # Triggers calculate_totals callback
  end

  def format_currency(amount)
    return "$0" if amount.nil? || amount.zero?

    "$#{amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end
end
