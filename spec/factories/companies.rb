FactoryBot.define do
  factory :company do
    name { "MyString" }
    logo { nil }
    address { "MyString" }
    city { "MyString" }
    state { "MyString" }
    zip_code { "MyString" }
    phone { "MyString" }
    email { "MyString" }
    license_number { "MyString" }
    default_labor_markup { "9.99" }
    default_material_markup { "9.99" }
    default_terms { "MyText" }
    default_payment_terms { "MyText" }
    legal_boilerplate { "MyText" }
    settings { "" }
  end
end
