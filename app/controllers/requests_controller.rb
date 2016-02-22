class RequestsController < ApplicationController
  before_filter :ensure_logged_in, only: [:create, :update, :edit, :destroy]
  def index
      @requests = Request.all 
  end

  def show
    @request = Request.find(params[:id])
  end

  def new
    @request = Request.new
  end
  
  def create
     # For several tags, concatenate the tag boxes into
    # one string, checking for empty boxes and removing them
    7.times do |count|
      counter = "hashtag_box_#{count}".to_sym
      unless (params[counter].to_s.empty?)
        @hashtagboxes = @hashtagboxes.to_s + params[counter].to_s.capitalize << ', ' 
      end
    end

    # Strip the last comma from multiple choice questions
    if @hashtagboxes
      @hashtagboxes = @hashtagboxes[0...-1].chomp(",")
    end

    @request = Request.new(request_params)
    @request.user_id = current_user.id
    @request.tags = @hashtagboxes
    if @request.save && @request.valid?
      redirect_to @request, notice: "request Successfully Added!"
    else
      flash[:message] = "This request has already been posted or Something didn't validate"
      render 'new'
    end
  end
  
  def edit
    @request = Request.find(params[:id])
  end

  def update
    @request = Request.find(params[:id])
    if @request.update_attributes(request_params)
      redirect_to @request
    else
      render :edit
    end
    
  end

  def destroy
    @request = Request.find(params[:id])
    @request.destroy
    redirect_to user_path(current_user)
  end

  private
  def request_params
    params.require(:request).permit(:title, :description, :user_id, :tags, :postal_code, :timeframe)
  end

end
