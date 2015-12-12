class ItemsController < ApplicationController

  def index
    # @query = params[:search]

    # if @query
    #   @items = []
    #   %w[title description tags].each do |field|
    #     @items += Item.where("LOWER(#{field}) LIKE LOWER(?)", "%#{params[:search]}%") 
    #   end
    # else
      @items = Item.all 
    # end

    # respond_to do |format|
    #   format.html
    #   format.js
    # end
  end

  def show
    @item = Item.find(params[:id])
    @review = @item.reviews.build
    @price = Price.where(item_id: @item.id).first
    # if current_user
    # @rating = current_user.ratings.find_by(:item => @item)
    # end
  end

  def new
    @item = Item.new
    @price = Price.new
  end
  
  def create
    @item = Item.new(item_params)
    if @item.save
    # @item.user_id = current_user.id
      redirect_to @item, notice: "Item Successfully Added!"
    else
      flash[:message] = "Something did not validate"
      render 'new'
    end
  end
  
  def edit
    @item = Item.find(params[:id])
  end

  def update
    @item = Item.find(params[:id])
    if @item.update_attributes(item_params)
      redirect_to @item
    else
      render :edit
    end
    
  end

  def destroy
    @item = Item.find(params[:id])
    @item.destroy
    # redirect_to user_path(current_user)
  end

  private
  def item_params
    params.require(:item).permit(:title, :description, :image, :user_id, :deposit, :tags, prices_attributes: [:id, :timeframe, :amount])
  end

end
