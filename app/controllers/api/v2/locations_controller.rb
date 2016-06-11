module Api::V2
  class LocationsController < BaseController
    def index
      location = Location.all
      if city = params[:city]
        location = Location.where(city: city)
      end
      render json: location, status: :ok
    end

    def show
      location = Location.find(params[:id])
      if !location.nil?
        render json: location
      else
        render json: {
          error: "No such location; check the location id",
          status: 400
        }, status: 400
      end
    end

    def create
      location = Location.new(location_params)

      if location.save
        render nothing: true, status: 204#, location: user
      else
        render json: location.errors, status: 422
      end
    end

    def destroy
      location = Location.find(params[:id])

      if !location.nil?
        Location.destroy(params[:id])
        head :no_content
      else
        render json: {
          error: "No such location; check the location id",
          status: 400
        }, status: 400
      end
    end

    private

      def location_params
        params.require(:locations).permit(:city, :country, :postal_code, :user_id)
      end
  end
end
