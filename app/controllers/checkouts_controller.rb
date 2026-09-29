class CheckoutsController < ApplicationController
  before_action :authenticate_user!

  def new
    @booking = current_user.bookings.find(params[:booking_id])

    session = Stripe::Checkout::Session.create(
      payment_method_types: ["card"],
      line_items: [{
        price_data: {
          currency: "usd",
          product_data: { name: @booking.listing.title },
          unit_amount: (@booking.total_price * 100).to_i # Stripe usa centavos
        },
        quantity: 1
      }],
      mode: "payment",
      success_url: booking_url(@booking),
      cancel_url: booking_url(@booking),
      metadata: { booking_id: @booking.id }
    )

    redirect_to session.url, allow_other_host: true
  end
end