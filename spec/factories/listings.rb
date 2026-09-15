FactoryBot.define do
  factory :listing do
    title { "MyString" }
    description { "MyText" }
    price_per_night { "9.99" }
    address { "MyString" }
    latitude { 1.5 }
    longitude { 1.5 }
    host { nil }
  end
end
