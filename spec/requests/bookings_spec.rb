require "rails_helper"

RSpec.describe "Bookings", type: :request do
  let(:host) { create(:user, :host) }
  let(:listing) { create(:listing, host: host) }
  let(:guest) { create(:user) }
  let(:other_guest) { create(:user) }

  describe "GET /listings/:listing_id/bookings/new" do
    it "requiere autenticación" do
      get new_listing_booking_path(listing)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "muestra el formulario cuando hay usuario autenticado" do
      sign_in guest
      get new_listing_booking_path(listing)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /listings/:listing_id/bookings" do
    before { sign_in guest }

    let(:valid_params) do
      { booking: { check_in: Date.new(2026, 11, 1), check_out: Date.new(2026, 11, 5) } }
    end

    it "crea una reserva con datos válidos" do
      expect {
        post listing_bookings_path(listing), params: valid_params
      }.to change(Booking, :count).by(1)
    end

    it "asigna el guest actual, no uno arbitrario del params" do
      post listing_bookings_path(listing), params: valid_params
      expect(Booking.last.guest).to eq(guest)
    end

    it "calcula el total_price en el servidor a partir de las noches" do
      post listing_bookings_path(listing), params: valid_params
      # 4 noches (1 al 5) * price_per_night del listing
      expected = 4 * listing.price_per_night
      expect(Booking.last.total_price).to eq(expected)
    end

    it "ignora un total_price manipulado desde el cliente" do
      hacked_params = valid_params.deep_merge(booking: { total_price: 1 })
      post listing_bookings_path(listing), params: hacked_params
      expect(Booking.last.total_price).not_to eq(1)
    end

    it "no crea la reserva si las fechas se solapan con una existente" do
      create(:booking, listing: listing, guest: other_guest,
             check_in: Date.new(2026, 11, 2), check_out: Date.new(2026, 11, 6))

      expect {
        post listing_bookings_path(listing), params: valid_params
      }.not_to change(Booking, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "no crea la reserva sin check_in" do
      invalid_params = { booking: { check_in: nil, check_out: Date.new(2026, 11, 5) } }
      expect {
        post listing_bookings_path(listing), params: invalid_params
      }.not_to change(Booking, :count)
    end
  end

  describe "GET /bookings/:id" do
    it "permite ver la propia reserva" do
      booking = create(:booking, listing: listing, guest: guest)
      sign_in guest
      get booking_path(booking)
      expect(response).to have_http_status(:ok)
    end

    it "no permite ver la reserva de otro guest" do
      booking = create(:booking, listing: listing, guest: other_guest)
      sign_in guest
      get booking_path(booking)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /bookings/:id" do
    it "cancela la propia reserva (no la borra)" do
      booking = create(:booking, listing: listing, guest: guest)
      sign_in guest

      expect {
        delete booking_path(booking)
      }.not_to change(Booking, :count)

      expect(booking.reload.status).to eq("cancelled")
    end

    it "no permite cancelar la reserva de otro guest" do
      booking = create(:booking, listing: listing, guest: other_guest)
      sign_in guest

      delete booking_path(booking)

      expect(response).to have_http_status(:not_found)
      expect(booking.reload.status).not_to eq("cancelled")
    end
  end

  describe "GET /bookings" do
    it "lista solo las reservas del usuario actual" do
      mine = create(:booking, listing: listing, guest: guest)
      create(:booking, listing: listing, guest: other_guest,
             check_in: Date.new(2026, 12, 1), check_out: Date.new(2026, 12, 5))

      sign_in guest
      get bookings_path

      expect(response.body).to include(mine.listing.title)
    end
  end
end