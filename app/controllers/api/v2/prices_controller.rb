module Api::V1
  class PricesController < BaseController
    def index
      price = Price.all
      if item_id = params[:item_id]
        price = Price.where(item_id: item_id)
      end
      render json: price, status: :ok
    end

    def show
      price = Price.find(params[:id])
      if !price.nil?
        render json: price
      else
        render json: {
          error: "No such price; check the price id",
          status: 400
        }, status: 400
      end
    end

    def create
      price = Price.new(price_params)

      if price.save
        render nothing: true, status: 204#, location: user
      else
        render json: price.errors, status: 422
      end
    end

    def destroy
      price = Price.find(params[:id])

      if !price.nil?
        Price.destroy(params[:id])
        head :no_content
      else
        render json: {
          error: "No such price; check the price id",
          status: 400
        }, status: 400
      end
    end

    private

      def price_params
        params.require(:prices).permit(:time_frame, :amount, :item_id)
      end
  end
end
