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

  describe "#average_rating" do
    it "devuelve nil si no tiene reviews" do
      listing = create(:listing)
      expect(listing.average_rating).to be_nil
    end

    it "calcula el promedio redondeado a 1 decimal" do
      listing = create(:listing)
      booking1 = create(:booking, :completed, listing: listing)
      booking2 = create(:booking, :completed, listing: listing, check_in: 20.days.ago.to_date, check_out: 15.days.ago.to_date)

      create(:review, booking: booking1, rating: 5)
      create(:review, booking: booking2, rating: 4)

      expect(listing.average_rating).to eq(4.5)
    end
  end
end