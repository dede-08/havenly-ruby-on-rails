module Host
  class ListingsController < BaseController
    before_action :set_listing, only: [:show, :edit, :update, :destroy]

    def index
      @listings = current_user.listings
    end

    def show
    end

    def new
      @listing = current_user.listings.build
    end

    def create
      @listing = current_user.listings.build(listing_params)
      if @listing.save
        redirect_to host_listing_path(@listing), notice: "Listing creado correctamente."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @listing.update(listing_params)
        redirect_to host_listing_path(@listing), notice: "Listing actualizado."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @listing.destroy
      redirect_to host_listings_path, notice: "Listing eliminado."
    end

    private

    def set_listing
      # Importante: scoped a current_user.listings, así un host no puede
      # editar/borrar el listing de otro host cambiando el id en la URL
      @listing = current_user.listings.find(params[:id])
    end

    def listing_params
      params.require(:listing).permit(:title, :description, :price_per_night, :address, :latitude, :longitude, photos: [])
    end
  end
end