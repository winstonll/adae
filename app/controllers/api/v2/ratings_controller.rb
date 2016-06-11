module Api::V2
  class RatingsController < BaseController
    def index
      rating = Rating.all
      if item_id = params[:item_id]
        rating = Rating.where(item_id: item_id)
      end
      render json: rating, status: :ok
    end

    def show
      rating = Rating.find(params[:id])
      if !rating.nil?
        render json: rating
      else
        render json: {
          error: "No such rating; check the rating id",
          status: 400
        }, status: 400
      end
    end

    def create
      rating = Rating.new(rating_params)

      if rating.save
        render nothing: true, status: 204#, location: user
      else
        render json: rating.errors, status: 422
      end
    end

    def destroy
      rating = Rating.find(params[:id])

      if !rating.nil?
        Rating.destroy(params[:id])
        head :no_content
      else
        render json: {
          error: "No such rating; check the rating id",
          status: 400
        }, status: 400
      end
    end

    private

      def rating_params
        params.require(:ratings).permit(:score, :user_id, :item_id)
      end
  end
end
