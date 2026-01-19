FactoryBot.define do
  factory :quote do
    company { nil }
    user { nil }
    client { nil }
    quote_number { "MyString" }
    status { 1 }
    template_type { 1 }
    project_address { "MyString" }
    project_city { "MyString" }
    project_state { "MyString" }
    project_zip_code { "MyString" }
    project_size { 1 }
    total_range_low { "9.99" }
    total_range_high { "9.99" }
    approved_changes_total { "9.99" }
    notes { "MyText" }
    terms { "MyText" }
    payment_terms { "MyText" }
    timeline_estimate { "MyString" }
    valid_days { 1 }
    client_view_token { "MyString" }
    sent_at { "2026-01-18 19:02:24" }
    viewed_at { "2026-01-18 19:02:24" }
    accepted_at { "2026-01-18 19:02:24" }
    signed_at { "2026-01-18 19:02:24" }
    signature_data { "" }
  end
end
