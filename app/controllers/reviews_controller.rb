class ReviewsController < ApplicationController
  before_filter :load_item
  before_filter :load_review, only:[:show, :edit, :update, :destroy]
  
  def show
    
  end

  def create
    @review = @item.reviews.build(review_params)
    if current_user
      @review.user = current_user
    end
    respond_to do |format|
      if @review.save
        format.html {redirect_to item_path(@item.id), notice: 'Review added successfully.' }
        format.js {} # This will look for app/views/reviews/create.js.erb
      else
        format.html {render 'items/show', alert: 'There was an error.' }
        format.js {} # This will look for app/views/reviews/create.js.erb
      end
    end
  end

  def edit
    
  end

  def update
      if @review.update_attributes(review_params)
        redirect_to user_path(current_user)
      else
        render :edit
    end
  end

  def destroy
    @review.destroy
    redirect_to user_path(current_user)
  end

  private
  
  def review_params
    params.require(:review).permit(:comment, :item_id)
  end

  def load_item
    item = params[:item_id]
    @item = Item.find(item)
  end

  def load_review
    @review = Review.find(params[:id])
  end
end
