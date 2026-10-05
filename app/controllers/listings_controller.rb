class ListingsController < ApplicationController
  def index
    @q = Listing.ransack(params[:q])
    @listings = @q.result(distinct: true)
    @listings = @listings.available_between(parse_date(params[:check_in]), parse_date(params[:check_out]))

    if params[:location].present?
      coordinates = Geocoder.search(params[:location]).first&.coordinates

      if coordinates
        @listings = @listings.near(coordinates, 20, units: :km)
      else
        @listings = @listings.none
        flash.now[:alert] = "No encontramos esa ubicación, intenta con otro término."
      end
    end
  end

  def show
    @listing = Listing.find(params[:id])
  end

  private

  def parse_date(value)
    Date.parse(value)
  rescue ArgumentError, TypeError
    nil
  end
end