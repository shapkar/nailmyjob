FactoryBot.define do
  factory :client do
    company { nil }
    name { "MyString" }
    email { "MyString" }
    phone { "MyString" }
    address { "MyString" }
    city { "MyString" }
    state { "MyString" }
    zip_code { "MyString" }
    notes { "MyText" }
    magic_link_token { "MyString" }
    magic_link_expires_at { "2026-01-18 19:02:08" }
  end
end
