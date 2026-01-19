FactoryBot.define do
  factory :line_item do
    quote { nil }
    category { 1 }
    description { "MyString" }
    quality_tier { 1 }
    is_allowance { false }
    range_low { "9.99" }
    range_high { "9.99" }
    suggested_range_low { "9.99" }
    suggested_range_high { "9.99" }
    final_selection { "MyString" }
    final_price { "9.99" }
    selection_status { 1 }
    internal_notes { "MyText" }
    sort_order { 1 }
  end
end
