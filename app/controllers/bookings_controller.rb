class BookingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @bookings = current_user.bookings.includes(:listing).order(check_in: :desc)
  end

  def new
    @listing = Listing.find(params[:listing_id])
    @booking = @listing.bookings.build
  end

  def create
    @listing = Listing.find(params[:listing_id])
    @booking = @listing.bookings.build(booking_params)
    @booking.guest = current_user
    @booking.total_price = calculate_total_price(@booking)

    if @booking.save
      redirect_to booking_path(@booking), notice: "¡Reserva confirmada!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @booking = current_user.bookings.find(params[:id])
  end

  def destroy
    @booking = current_user.bookings.find(params[:id])
    @booking.update!(status: :cancelled)
    redirect_to bookings_path, notice: "Reserva cancelada."
  end

  private

  def booking_params
    params.require(:booking).permit(:check_in, :check_out)
  end

  def calculate_total_price(booking)
    return 0 if booking.check_in.blank? || booking.check_out.blank?

    nights = (booking.check_out - booking.check_in).to_i
    nights * booking.listing.price_per_night
  end
end