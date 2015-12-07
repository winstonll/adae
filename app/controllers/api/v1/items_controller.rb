module Api::V1
  class ItemsController < ApplicationController
    def index
      item = Item.all
      if title = params[:title]
        item = Item.where(title: title)
      end
      render json: item, status: :ok
    end

    def show
      item = Item.find(params[:id])
      if !item.nil?
        render json: user
      else
        render json: {
          error: "No such item; check the item id",
          status: 400
        }, status: 400
      end
    end

    def create
      item = Item.new(item_params)

      if item.save
        render nothing: true, status: 204#, location: user
      else
        render json: item.errors, status: 422
      end
    end

    def destroy
      item = Item.find(params[:id])

      if !item.nil?
        Item.destroy(params[:id])
        head :no_content
      else
        render json: {
          error: "No such item; check the item id",
          status: 400
        }, status: 400
      end
    end

    private

      def item_params
        params.require(:items).permit(:title, :description, :user_id, :deposit,
        :type, :tags )
      end
  end
end
