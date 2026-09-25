require "rails_helper"

RSpec.describe Booking, type: :model do
  let(:host) { create(:user, :host) }
  let(:listing) { create(:listing, host: host) }
  let(:guest) { create(:user) }

  describe "validaciones básicas" do
    it "es válido con atributos válidos" do
      booking = build(:booking, listing: listing, guest: guest)
      expect(booking).to be_valid
    end

    it "no es válido sin check_in" do
      booking = build(:booking, listing: listing, guest: guest, check_in: nil)
      expect(booking).not_to be_valid
    end

    it "no es válido sin check_out" do
      booking = build(:booking, listing: listing, guest: guest, check_out: nil)
      expect(booking).not_to be_valid
    end

    it "no es válido si check_out es igual a check_in" do
      date = Date.tomorrow
      booking = build(:booking, listing: listing, guest: guest, check_in: date, check_out: date)
      expect(booking).not_to be_valid
      expect(booking.errors[:check_out]).to be_present
    end

    it "no es válido si check_out es anterior a check_in" do
      booking = build(:booking, listing: listing, guest: guest,
                       check_in: Date.new(2026, 10, 10), check_out: Date.new(2026, 10, 5))
      expect(booking).not_to be_valid
      expect(booking.errors[:check_out]).to be_present
    end
  end

  describe "no-solapamiento de fechas" do
    before do
      create(:booking, listing: listing, guest: guest,
             check_in: Date.new(2026, 10, 1), check_out: Date.new(2026, 10, 5))
    end

    it "rechaza una reserva que se cruza al inicio" do
      booking = build(:booking, listing: listing, guest: guest,
                       check_in: Date.new(2026, 9, 28), check_out: Date.new(2026, 10, 2))
      expect(booking).not_to be_valid
      expect(booking.errors[:base]).to include("Ya existe una reserva para estas fechas")
    end

    it "rechaza una reserva que se cruza al final" do
      booking = build(:booking, listing: listing, guest: guest,
                       check_in: Date.new(2026, 10, 3), check_out: Date.new(2026, 10, 8))
      expect(booking).not_to be_valid
    end

    it "rechaza una reserva completamente contenida dentro de otra" do
      booking = build(:booking, listing: listing, guest: guest,
                       check_in: Date.new(2026, 10, 2), check_out: Date.new(2026, 10, 3))
      expect(booking).not_to be_valid
    end

    it "rechaza una reserva que contiene completamente a otra" do
      booking = build(:booking, listing: listing, guest: guest,
                       check_in: Date.new(2026, 9, 25), check_out: Date.new(2026, 10, 10))
      expect(booking).not_to be_valid
    end

    it "acepta una reserva que empieza justo cuando termina la anterior" do
      booking = build(:booking, listing: listing, guest: guest,
                       check_in: Date.new(2026, 10, 5), check_out: Date.new(2026, 10, 8))
      expect(booking).to be_valid
    end

    it "acepta una reserva que termina justo cuando empieza la anterior" do
      booking = build(:booking, listing: listing, guest: guest,
                       check_in: Date.new(2026, 9, 25), check_out: Date.new(2026, 10, 1))
      expect(booking).to be_valid
    end

    it "acepta fechas iguales en un listing distinto" do
      other_listing = create(:listing, host: host, title: "Otro depa")
      booking = build(:booking, listing: other_listing, guest: guest,
                       check_in: Date.new(2026, 10, 1), check_out: Date.new(2026, 10, 5))
      expect(booking).to be_valid
    end

    it "ignora reservas canceladas al validar solapamiento" do
      cancelled = create(:booking, listing: listing, guest: guest, status: :cancelled,
                          check_in: Date.new(2026, 11, 1), check_out: Date.new(2026, 11, 5))
      booking = build(:booking, listing: listing, guest: guest,
                       check_in: Date.new(2026, 11, 2), check_out: Date.new(2026, 11, 4))
      expect(booking).to be_valid
    end

    it "permite actualizar una reserva existente sin chocar consigo misma" do
      existing = Booking.first
      existing.total_price = 999
      expect(existing).to be_valid
    end
  end

  describe "asociaciones" do
    it "pertenece a un listing" do
      booking = build(:booking, listing: nil, guest: guest)
      expect(booking).not_to be_valid
    end

    it "pertenece a un guest" do
      booking = build(:booking, listing: listing, guest: nil)
      expect(booking).not_to be_valid
    end
  end
end