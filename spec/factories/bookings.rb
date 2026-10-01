FactoryBot.define do
  factory :booking do
    association :listing
    association :guest, factory: :user
    check_in { Date.tomorrow }
    check_out { Date.tomorrow + 3.days }
    total_price { 360 }
    status { :pending }

    trait :completed do
      status { :confirmed }
      check_in { 10.days.ago.to_date }
      check_out { 5.days.ago.to_date }
    end
  end
end