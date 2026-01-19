# frozen_string_literal: true

FactoryBot.define do
  factory :job do
    association :quote
    association :company
    association :client
    association :user

    job_number { "J#{Time.current.strftime('%y%m')}#{rand(1000..9999)}" }
    status { :active }
    contracted_amount_low { 25_000 }
    contracted_amount_high { 35_000 }
    change_orders_total { 0 }
    client_view_token { SecureRandom.urlsafe_base64(32) }

    trait :with_address do
      project_address { Faker::Address.street_address }
      project_city { Faker::Address.city }
      project_state { Faker::Address.state_abbr }
      project_zip_code { Faker::Address.zip_code }
    end

    trait :with_dates do
      start_date { 1.week.ago.to_date }
      estimated_completion_date { 8.weeks.from_now.to_date }
    end

    trait :on_hold do
      status { :on_hold }
    end

    trait :completed do
      status { :completed }
      start_date { 2.months.ago.to_date }
      actual_completion_date { Date.current }
    end

    trait :cancelled do
      status { :cancelled }
    end
  end
end
