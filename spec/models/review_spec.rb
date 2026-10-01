require "rails_helper"

RSpec.describe Review, type: :model do
  describe "validaciones básicas" do
    it "es válido con atributos válidos" do
      review = build(:review)
      expect(review).to be_valid
    end

    it "no es válido sin rating" do
      review = build(:review, rating: nil)
      expect(review).not_to be_valid
    end

    it "no es válido con rating fuera de 1..5" do
      review = build(:review, rating: 6)
      expect(review).not_to be_valid
    end

    it "no es válido con rating 0" do
      review = build(:review, rating: 0)
      expect(review).not_to be_valid
    end

    it "es válido en los bordes del rango (1 y 5)" do
      expect(build(:review, rating: 1)).to be_valid
      expect(build(:review, rating: 5)).to be_valid
    end
  end

  describe "solo se puede reviewear un booking completado" do
    it "no es válido si el booking está pending" do
      booking = create(:booking, status: :pending)
      review = build(:review, booking: booking)
      expect(review).not_to be_valid
      expect(review.errors[:base]).to include("Solo puedes dejar una review después de completar tu estadía")
    end

    it "no es válido si el booking está confirmed pero el check_out es futuro" do
      booking = create(:booking, status: :confirmed, check_in: Date.tomorrow, check_out: Date.tomorrow + 3.days)
      review = build(:review, booking: booking)
      expect(review).not_to be_valid
    end

    it "no es válido si el booking está cancelled, aunque el check_out sea pasado" do
      booking = create(:booking, status: :cancelled, check_in: 10.days.ago.to_date, check_out: 5.days.ago.to_date)
      review = build(:review, booking: booking)
      expect(review).not_to be_valid
    end

    it "es válido si el booking está confirmed y el check_out ya pasó" do
      booking = create(:booking, :completed)
      review = build(:review, booking: booking)
      expect(review).to be_valid
    end
  end

  describe "unicidad" do
    it "no permite más de una review por booking" do
      booking = create(:booking, :completed)
      create(:review, booking: booking)

      duplicate = build(:review, booking: booking)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:booking_id]).to be_present
    end
  end

  describe "delegación a booking" do
    it "expone el guest y el listing del booking" do
      review = create(:review)
      expect(review.guest).to eq(review.booking.guest)
      expect(review.listing).to eq(review.booking.listing)
    end
  end
end