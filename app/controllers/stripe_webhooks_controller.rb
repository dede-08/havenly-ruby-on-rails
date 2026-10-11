class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError, Stripe::SignatureVerificationError
      return head :bad_request
    end

    case event.type
    when "checkout.session.completed"
      session = event.data.object
      booking = Booking.find(session.metadata.booking_id)

      if booking.pending?
        booking.update!(status: :confirmed)
        BookingMailer.confirmation(booking).deliver_later
      end
    end

    head :ok
  end
end