FactoryBot.define do
  factory :listing do
    title { "Depa en Miraflores" }
    description { "Lindo depa con vista al mar" }
    price_per_night { 120.0 }
    address { "Av. Larco 123, Miraflores" }
    latitude { -12.1211 }
    longitude { -77.0296 }
    association :host, factory: [:user, :host]

    trait :with_photo do
      after(:build) do |listing|
        listing.photos.attach(
          io: StringIO.new("fake image content"),
          filename: "test.jpg",
          content_type: "image/jpeg"
        )
      end
    end
  end
end