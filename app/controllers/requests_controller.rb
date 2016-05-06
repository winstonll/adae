class RequestsController < ApplicationController
  before_filter :ensure_logged_in, only: [:create, :update, :edit, :destroy]
  def index
      @requests = Request.all.paginate(:page => params[:page], :per_page => 8).order('created_at DESC')
      gon.map_requests = @requests.pluck(:latitude, :longitude, :id, :title)
      @user = current_user
      @items = Item.where(status: "Listed", user_id: @user)
  end

  def new
    @request = Request.new
  end

  def show
    @request = Request.find(params[:id])
    gon.map_request = Request.where(id: @request.id).pluck(:latitude, :longitude, :id)
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

    geocode = Geocoder.search(request_params[:postal_code]).first

    if !geocode.nil?
      @request.latitude = geocode.latitude
      @request.longitude = geocode.longitude
    end

    @request.user_id = current_user.id
    @request.tags = @hashtagboxes
    if @request.save && @request.valid?
      redirect_to requests_path, notice: "request Successfully Added!"
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

     7.times do |count|
      counter = "hashtag_box_#{count}".to_sym
      unless (params[counter].to_s.empty?)
        @hashtagboxes = @hashtagboxes.to_s + params[counter].to_s.capitalize.strip << ', '
      end
    end

    # Strip the last comma from multiple choice questions
    if @hashtagboxes
      @hashtagboxes = @hashtagboxes[0...-1].chomp(",")

      @request.tags = @hashtagboxes
    end

    geocode = Geocoder.search(request_params[:postal_code]).first

    if !geocode.nil?
      @request.latitude = geocode.latitude
      @request.longitude = geocode.longitude
    end

    if @request.update_attributes(request_params)
      redirect_to requests_path, notice: "Shoutout Successfully Edited!"
    else
      render :edit
    end
    
  end

  def destroy
    @request = Request.find(params[:id])
    @request.destroy
    redirect_to user_path(current_user)
  end

  def send_system_message(user)
    @recipient = user
    @user = current_user
    ContactMailer.adaebot_message(@user, @recipient).deliver_now
  end

  private
  def request_params
    params.require(:request).permit(:title, :description, :user_id, :tags, :postal_code, :timeframe)
  end

end
