FactoryBot.define do
  factory :booking do
    association :listing
    association :guest, factory: :user
    check_in { Date.tomorrow }
    check_out { Date.tomorrow + 3.days }
    total_price { 360 }
    status { :pending }
  end
end