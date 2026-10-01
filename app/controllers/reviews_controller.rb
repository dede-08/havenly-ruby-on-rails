class ReviewsController < ApplicationController
  before_action :authenticate_user!

  def new
    @booking = current_user.bookings.find(params[:booking_id])
    @review = @booking.build_review
  end

  def create
    @booking = current_user.bookings.find(params[:booking_id])
    @review = @booking.build_review(review_params)

    if @review.save
      redirect_to listing_path(@booking.listing), notice: "¡Gracias por tu review!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end