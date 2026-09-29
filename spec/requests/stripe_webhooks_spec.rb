require "rails_helper"

RSpec.describe "StripeWebhooks", type: :request do
  let(:host) { create(:user, :host) }
  let(:listing) { create(:listing, host: host) }
  let(:guest) { create(:user) }
  let(:booking) { create(:booking, listing: listing, guest: guest, status: :pending) }

  def stripe_event(type:, booking_id:)
    Stripe::Event.construct_from(
      id: "evt_test_#{SecureRandom.hex(8)}",
      type: type,
      data: {
        object: {
          id: "cs_test_#{SecureRandom.hex(8)}",
          metadata: { booking_id: booking_id.to_s }
        }
      }
    )
  end

  describe "POST /webhooks/stripe" do
    context "cuando el evento es checkout.session.completed" do
      it "confirma el booking correspondiente" do
        event = stripe_event(type: "checkout.session.completed", booking_id: booking.id)
        allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

        post "/webhooks/stripe", params: {}, headers: { "HTTP_STRIPE_SIGNATURE" => "fake_sig" }

        expect(response).to have_http_status(:ok)
        expect(booking.reload.status).to eq("confirmed")
      end
    end

    context "cuando el evento no es relevante" do
      it "responde ok pero no cambia el booking" do
        event = stripe_event(type: "charge.refunded", booking_id: booking.id)
        allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

        post "/webhooks/stripe", params: {}, headers: { "HTTP_STRIPE_SIGNATURE" => "fake_sig" }

        expect(response).to have_http_status(:ok)
        expect(booking.reload.status).to eq("pending")
      end
    end

    context "cuando la firma es inválida" do
      it "responde 400 sin tocar el booking" do
        allow(Stripe::Webhook).to receive(:construct_event)
          .and_raise(Stripe::SignatureVerificationError.new("firma inválida", "fake_sig"))

        post "/webhooks/stripe", params: {}, headers: { "HTTP_STRIPE_SIGNATURE" => "bad_sig" }

        expect(response).to have_http_status(:bad_request)
        expect(booking.reload.status).to eq("pending")
      end
    end

    context "cuando el payload no es JSON válido" do
      it "responde 400" do
        allow(Stripe::Webhook).to receive(:construct_event)
          .and_raise(JSON::ParserError.new("payload inválido"))

        post "/webhooks/stripe", params: {}, headers: { "HTTP_STRIPE_SIGNATURE" => "fake_sig" }

        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end