class RatingsController < ApplicationController
  before_filter :load_item
  before_filter :ensure_logged_in
  before_filter :load_rating, only:[:show, :edit, :update, :destroy]
 
  def show

  end

  def new
    @rating = Rating.new
  end

  def create
   @rating = @item.ratings.build(rating_params)
    if current_user
      @rating.user = current_user
    end

    if @rating.save
      redirect_to @item, notice: 'Rating created succesfully'
    else
      render 'items/show'
    end
  end

  def edit
    @rating = Rating.find(params[:id])
  end

  def update
      if @rating.update_attributes(rating_params)
        redirect_to @item
      else
        render :edit
    end
  end

  def destroy
    @rating.destroy
    redirect_to user_path(current_user)
  end

  private

  def rating_params
    params.require(:rating).permit(:score, :item_id, :user_id)
  end

  def load_item
    item = params[:item_id]
    @item = Item.find(item)
  end

  def load_rating
    @rating = Rating.find(params[:id])
  end
end
