require "rails_helper"

RSpec.describe Listing, type: :model do
  it "es válido con atributos válidos" do
    listing = build(:listing)
    expect(listing).to be_valid
  end

  it "no es válido sin título" do
    listing = build(:listing, title: nil)
    expect(listing).not_to be_valid
  end

  it "no es válido sin descripción" do
    listing = build(:listing, description: nil)
    expect(listing).not_to be_valid
  end

  it "no es válido sin precio por noche" do
    listing = build(:listing, price_per_night: nil)
    expect(listing).not_to be_valid
  end

  it "no es válido con precio negativo o cero" do
    listing = build(:listing, price_per_night: 0)
    expect(listing).not_to be_valid
  end

  it "pertenece a un host" do
    listing = build(:listing, host: nil)
    expect(listing).not_to be_valid
  end
end