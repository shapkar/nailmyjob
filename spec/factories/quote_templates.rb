FactoryBot.define do
  factory :quote_template do
    name { "MyString" }
    template_type { 1 }
    is_system { false }
    company { nil }
    line_items_config { "" }
  end
end
