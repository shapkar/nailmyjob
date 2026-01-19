# frozen_string_literal: true

class QuoteTemplate < ApplicationRecord
  # Associations
  belongs_to :company, optional: true

  # Enums
  enum :template_type, {
    kitchen: 0,
    bathroom: 1,
    custom: 2
  }, default: :kitchen

  # Validations
  validates :name, presence: true
  validates :template_type, presence: true

  # Scopes
  scope :system_templates, -> { where(is_system: true) }
  scope :custom_templates, -> { where(is_system: false) }
  scope :for_company, ->(company) { where(company: company).or(where(is_system: true)) }

  # Class Methods
  def self.default_kitchen_template
    {
      name: "Kitchen Remodel",
      template_type: :kitchen,
      is_system: true,
      line_items_config: kitchen_line_items_config
    }
  end

  def self.default_bathroom_template
    {
      name: "Bathroom Remodel",
      template_type: :bathroom,
      is_system: true,
      line_items_config: bathroom_line_items_config
    }
  end

  def self.kitchen_line_items_config
    [
      {
        category: "cabinets",
        default_description: "Kitchen cabinets",
        is_allowance: true,
        has_quality_tiers: true,
        ranges: kitchen_cabinet_ranges
      },
      {
        category: "countertops",
        default_description: "Countertops",
        is_allowance: true,
        has_quality_tiers: true,
        ranges: kitchen_countertop_ranges
      },
      {
        category: "flooring",
        default_description: "Flooring",
        is_allowance: true,
        has_quality_tiers: true,
        ranges: kitchen_flooring_ranges
      },
      {
        category: "backsplash",
        default_description: "Backsplash",
        is_allowance: true,
        has_quality_tiers: true,
        ranges: kitchen_backsplash_ranges
      },
      {
        category: "appliances",
        default_description: "Appliances",
        is_allowance: true,
        has_quality_tiers: true,
        ranges: appliance_ranges
      },
      {
        category: "demo",
        default_description: "Demo & Prep",
        is_allowance: false,
        has_quality_tiers: false,
        ranges: kitchen_demo_ranges
      },
      {
        category: "electrical",
        default_description: "Electrical",
        is_allowance: false,
        has_quality_tiers: false,
        ranges: kitchen_electrical_ranges
      },
      {
        category: "plumbing",
        default_description: "Plumbing",
        is_allowance: false,
        has_quality_tiers: false,
        ranges: kitchen_plumbing_ranges
      },
      {
        category: "labor",
        default_description: "Labor & Project Management",
        is_allowance: false,
        has_quality_tiers: false,
        ranges: kitchen_labor_ranges
      }
    ]
  end

  def self.bathroom_line_items_config
    [
      {
        category: "cabinets",
        default_description: "Vanity cabinet",
        is_allowance: true,
        has_quality_tiers: true,
        ranges: bathroom_cabinet_ranges
      },
      {
        category: "countertops",
        default_description: "Vanity top",
        is_allowance: true,
        has_quality_tiers: true,
        ranges: bathroom_countertop_ranges
      },
      {
        category: "flooring",
        default_description: "Floor tile",
        is_allowance: true,
        has_quality_tiers: true,
        ranges: bathroom_flooring_ranges
      },
      {
        category: "backsplash",
        default_description: "Shower/tub tile",
        is_allowance: true,
        has_quality_tiers: true,
        ranges: bathroom_tile_ranges
      },
      {
        category: "plumbing",
        default_description: "Plumbing fixtures",
        is_allowance: true,
        has_quality_tiers: true,
        ranges: bathroom_fixture_ranges
      },
      {
        category: "demo",
        default_description: "Demo & Prep",
        is_allowance: false,
        has_quality_tiers: false,
        ranges: bathroom_demo_ranges
      },
      {
        category: "electrical",
        default_description: "Electrical",
        is_allowance: false,
        has_quality_tiers: false,
        ranges: bathroom_electrical_ranges
      },
      {
        category: "labor",
        default_description: "Labor & Project Management",
        is_allowance: false,
        has_quality_tiers: false,
        ranges: bathroom_labor_ranges
      }
    ]
  end

  # Budget Range Matrices (from PRD)
  def self.kitchen_cabinet_ranges
    {
      small: { good: [5000, 8000], better: [7000, 11000], best: [12000, 20000] },
      medium: { good: [7000, 11000], better: [10000, 16000], best: [18000, 32000] },
      large: { good: [10000, 16000], better: [15000, 24000], best: [28000, 50000] }
    }
  end

  def self.kitchen_countertop_ranges
    {
      small: { good: [1200, 2000], better: [2000, 3500], best: [4000, 6500] },
      medium: { good: [2000, 3500], better: [3500, 5500], best: [6000, 10000] },
      large: { good: [3500, 5500], better: [5500, 8500], best: [9000, 16000] }
    }
  end

  def self.kitchen_flooring_ranges
    {
      small: { good: [1000, 1800], better: [1500, 2800], best: [3000, 5000] },
      medium: { good: [1500, 2800], better: [2500, 4000], best: [4500, 7500] },
      large: { good: [2500, 4000], better: [3500, 5500], best: [6500, 11000] }
    }
  end

  def self.kitchen_backsplash_ranges
    {
      small: { good: [400, 800], better: [700, 1200], best: [1300, 2500] },
      medium: { good: [600, 1100], better: [900, 1600], best: [1800, 3500] },
      large: { good: [900, 1500], better: [1300, 2200], best: [2500, 5000] }
    }
  end

  def self.appliance_ranges
    {
      small: { good: [1500, 3000], better: [3000, 6000], best: [7000, 20000] },
      medium: { good: [1500, 3000], better: [3000, 6000], best: [7000, 20000] },
      large: { good: [1500, 3000], better: [3000, 6000], best: [7000, 20000] }
    }
  end

  def self.kitchen_demo_ranges
    {
      small: { good: [1000, 2000], better: [1000, 2000], best: [1000, 2000] },
      medium: { good: [1500, 2500], better: [1500, 2500], best: [1500, 2500] },
      large: { good: [2000, 3500], better: [2000, 3500], best: [2000, 3500] }
    }
  end

  def self.kitchen_electrical_ranges
    {
      small: { good: [1000, 2000], better: [1000, 2000], best: [1000, 2000] },
      medium: { good: [1500, 2500], better: [1500, 2500], best: [1500, 2500] },
      large: { good: [2000, 4000], better: [2000, 4000], best: [2000, 4000] }
    }
  end

  def self.kitchen_plumbing_ranges
    {
      small: { good: [1200, 2500], better: [1200, 2500], best: [1200, 2500] },
      medium: { good: [2000, 3500], better: [2000, 3500], best: [2000, 3500] },
      large: { good: [2500, 5000], better: [2500, 5000], best: [2500, 5000] }
    }
  end

  def self.kitchen_labor_ranges
    {
      small: { good: [5000, 8000], better: [5000, 8000], best: [5000, 8000] },
      medium: { good: [8000, 12000], better: [8000, 12000], best: [8000, 12000] },
      large: { good: [12000, 18000], better: [12000, 18000], best: [12000, 18000] }
    }
  end

  # Bathroom ranges
  def self.bathroom_cabinet_ranges
    {
      small: { good: [500, 1000], better: [1000, 2000], best: [2500, 5000] },
      medium: { good: [800, 1500], better: [1500, 3000], best: [3500, 7000] },
      large: { good: [1500, 3000], better: [3000, 5000], best: [6000, 12000] }
    }
  end

  def self.bathroom_countertop_ranges
    {
      small: { good: [300, 600], better: [500, 1000], best: [1000, 2000] },
      medium: { good: [500, 1000], better: [800, 1500], best: [1500, 3000] },
      large: { good: [800, 1500], better: [1200, 2500], best: [2500, 5000] }
    }
  end

  def self.bathroom_flooring_ranges
    {
      small: { good: [400, 800], better: [700, 1200], best: [1200, 2500] },
      medium: { good: [600, 1200], better: [1000, 1800], best: [1800, 3500] },
      large: { good: [1000, 2000], better: [1500, 3000], best: [3000, 6000] }
    }
  end

  def self.bathroom_tile_ranges
    {
      small: { good: [800, 1500], better: [1500, 2500], best: [2500, 5000] },
      medium: { good: [1200, 2500], better: [2500, 4000], best: [4000, 8000] },
      large: { good: [2000, 4000], better: [4000, 7000], best: [7000, 15000] }
    }
  end

  def self.bathroom_fixture_ranges
    {
      small: { good: [500, 1000], better: [1000, 2000], best: [2500, 5000] },
      medium: { good: [800, 1500], better: [1500, 3000], best: [3500, 7000] },
      large: { good: [1200, 2500], better: [2500, 5000], best: [5000, 12000] }
    }
  end

  def self.bathroom_demo_ranges
    {
      small: { good: [500, 1000], better: [500, 1000], best: [500, 1000] },
      medium: { good: [800, 1500], better: [800, 1500], best: [800, 1500] },
      large: { good: [1200, 2500], better: [1200, 2500], best: [1200, 2500] }
    }
  end

  def self.bathroom_electrical_ranges
    {
      small: { good: [400, 800], better: [400, 800], best: [400, 800] },
      medium: { good: [600, 1200], better: [600, 1200], best: [600, 1200] },
      large: { good: [1000, 2000], better: [1000, 2000], best: [1000, 2000] }
    }
  end

  def self.bathroom_labor_ranges
    {
      small: { good: [2500, 4000], better: [2500, 4000], best: [2500, 4000] },
      medium: { good: [4000, 6500], better: [4000, 6500], best: [4000, 6500] },
      large: { good: [6500, 10000], better: [6500, 10000], best: [6500, 10000] }
    }
  end

  # Instance Methods
  def get_range(category:, size:, tier: :better)
    item_config = line_items_config.find { |item| item["category"] == category.to_s }
    return nil unless item_config

    ranges = item_config["ranges"]
    return nil unless ranges

    size_ranges = ranges[size.to_s] || ranges[size.to_sym]
    return nil unless size_ranges

    tier_range = size_ranges[tier.to_s] || size_ranges[tier.to_sym]
    return nil unless tier_range

    { low: tier_range[0], high: tier_range[1] }
  end

  def build_line_items_for_quote(quote)
    line_items_config.each_with_index do |config, index|
      size = quote.project_size.to_sym
      tier = :better # default tier

      range = get_range(category: config["category"], size: size, tier: tier)

      quote.line_items.build(
        category: config["category"],
        description: config["default_description"],
        is_allowance: config["is_allowance"],
        quality_tier: config["has_quality_tiers"] ? tier : nil,
        range_low: range&.dig(:low),
        range_high: range&.dig(:high),
        suggested_range_low: range&.dig(:low),
        suggested_range_high: range&.dig(:high),
        sort_order: index + 1
      )
    end
  end
end
