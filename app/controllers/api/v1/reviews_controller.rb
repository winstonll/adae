module Api::V1
  class ReviewsController < ApplicationController
    def index
      review = Review.all
      if item_id = params[:item_id]
        review = Review.where(item_id: item_id)
      end
      render json: review, status: :ok
    end

    def show
      review = Review.find(params[:id])
      if !review.nil?
        render json: review
      else
        render json: {
          error: "No such review; check the review id",
          status: 400
        }, status: 400
      end
    end

    def create
      review = Review.new(review_params)

      if review.save
        render nothing: true, status: 204#, location: user
      else
        render json: review.errors, status: 422
      end
    end

    def destroy
      review = Review.find(params[:id])

      if !review.nil?
        Review.destroy(params[:id])
        head :no_content
      else
        render json: {
          error: "No such review; check the review id",
          status: 400
        }, status: 400
      end
    end

    private

      def review_params
        params.require(:reviews).permit(:comment, :user_id, :item_id)
      end
  end
end
