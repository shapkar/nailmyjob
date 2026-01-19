FactoryBot.define do
  factory :change_order do
    quote { nil }
    line_item { nil }
    co_number { 1 }
    status { 1 }
    description { "MyText" }
    amount { "9.99" }
    category { 1 }
    delays_schedule { false }
    delay_days { 1 }
    is_time_and_materials { false }
    hourly_rate { "9.99" }
    legal_boilerplate { "MyText" }
    signature_data { "" }
    signer_name { "MyString" }
    signer_email { "MyString" }
    signer_ip_address { "MyString" }
    signer_geolocation { "" }
    client_view_token { "MyString" }
    sent_at { "2026-01-18 19:02:45" }
    signed_at { "2026-01-18 19:02:45" }
  end
end
