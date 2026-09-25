FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    role { :guest }

    trait :host do
      role { :host }
    end
  end
end