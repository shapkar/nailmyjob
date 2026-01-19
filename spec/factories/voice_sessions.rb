FactoryBot.define do
  factory :voice_session do
    user { nil }
    quote { nil }
    change_order { nil }
    purpose { 1 }
    transcript { "MyText" }
    extracted_data { "" }
    confidence_score { "9.99" }
    duration_seconds { 1 }
    status { 1 }
  end
end
