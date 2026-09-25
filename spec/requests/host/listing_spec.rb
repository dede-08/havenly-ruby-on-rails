require "rails_helper"

RSpec.describe "Host::Listings", type: :request do
  let(:host_user) { create(:user, :host) }
  let(:guest_user) { create(:user) }

  describe "GET /host/listings" do
    context "cuando el usuario es host" do
      before { sign_in host_user }

      it "muestra sus propios listings" do
        my_listing = create(:listing, host: host_user)
        get host_listings_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(my_listing.title)
      end
    end

    context "cuando el usuario es guest" do
      before { sign_in guest_user }

      it "redirige, no permite acceso" do
        get host_listings_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "cuando no hay usuario autenticado" do
      it "redirige al login" do
        get host_listings_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /host/listings" do
    before { sign_in host_user }

    it "crea un listing con datos válidos" do
      expect {
        post host_listings_path, params: {
          listing: attributes_for(:listing)
        }
      }.to change(Listing, :count).by(1)
    end

    it "no crea un listing con datos inválidos" do
      expect {
        post host_listings_path, params: {
          listing: attributes_for(:listing, title: nil)
        }
      }.not_to change(Listing, :count)
    end
  end

  describe "PATCH /host/listings/:id" do
    before { sign_in host_user }

    it "no permite editar el listing de otro host" do
      other_host = create(:user, :host)
      other_listing = create(:listing, host: other_host)

      patch host_listing_path(other_listing), params: { listing: { title: "Hackeado" } }

      expect(response).to have_http_status(:not_found)
      expect(other_listing.reload.title).not_to eq("Hackeado")
    end
  end
end