class ItemsController < ApplicationController
  before_filter :ensure_logged_in, only: [:create, :update, :edit, :destroy]

  def index
      @items = Item.paginate(:page => params[:page], :per_page => 5).order('created_at DESC')

      gon.map_items = Item.pluck(:latitude, :longitude, :id)

      respond_to do |format|
        format.html #{ render :template => '/products_home.html.erb' }
        format.js { render :template => '/products_home.html.erb' } # Prodcuts home partial
      end
  end

  def show
    @item = Item.find(params[:id])
    @review = @item.reviews.build
    @prices = @item.prices
    @pictures = Picture.where(item_id: @item.id)

    if current_user
     @rating = current_user.ratings.find_by(:item => @item)
    end
  end

  def rent
    @item = Item.new
    @price = Price.new
  end

  def sell
    @item = Item.new
    @price = Price.new
  end

  def lease
    @item = Item.new
    @price = Price.new
  end

  def timeoffer
    @item = Item.new
    @price = Price.new
  end

  def new
    @item = Item.new
    @price = Price.new
  end

  def create
    # For several tags, concatenate the tag boxes into
    # one string, checking for empty boxes and removing them
    7.times do |count|
      counter = "tag_box_#{count}".to_sym
      unless (params[counter].to_s.empty?)
        @tagboxes = @tagboxes.to_s + params[counter].to_s.capitalize << ', '
      end
    end

    # Strip the last comma from multiple choice questions
    if @tagboxes
      @tagboxes = @tagboxes[0...-1].chomp(",")
    end

    @item = Item.create(item_params)

    geocode = Geocoder.search(item_params[:postal_code]).first

    if !geocode.nil?
      @item.latitude = geocode.latitude
      @item.longitude = geocode.longitude
    end

    @item.user_id = current_user.id
    @item.tags = @tagboxes

    if @item.save && @item.valid?

      if params[:images]
        params[:images].each { |image|
          @item.pictures.create(image: image)
        }
      end

      @picture = Picture.where(item_id: @item.id).first
      @item.photo_url = @picture.image.url(:small)
      @item.save

      redirect_to @item, notice: "Item Successfully Added!"
    else
      redirect_to :back, flash: {error: true}
    end
  end

  def edit
    @item = Item.find(params[:id])
  end

  def update

    @item = Item.find(params[:id])

    7.times do |count|
      counter = "tag_box_#{count}".to_sym
      unless (params[counter].to_s.empty?)
        @tagboxes = @tagboxes.to_s + params[counter].to_s.capitalize << ', '
      end
    end

    # Strip the last comma from multiple choice questions
    if @tagboxes
      @tagboxes = @tagboxes[0...-1].chomp(",")

      @item.tags = @tagboxes
    end

    geocode = Geocoder.search(item_params[:postal_code]).first

    if !geocode.nil?
      @item.latitude = geocode.latitude
      @item.longitude = geocode.longitude
    end

    if @item.update_attributes(item_params) && @item.valid?
=begin
      if params[:images]
        params[:images].each { |image|
          @item.pictures.create(image: image)
        }
      end

      @picture = Picture.where(item_id: @item.id).first
      @item.photo_url = @picture.image.url(:small)
      @item.save
=end
      redirect_to @item, notice: "Item Successfully Edited!"
    else
      redirect_to :back, flash: {error: true}
    end
  end

  def destroy
    @item = Item.find(params[:id])
    @item.destroy
    redirect_to user_path(current_user)
  end

  private

  def item_params
    params.require(:item).permit(:title, :photo, :description, :image, :user_id, :listing_type, :deposit, :tags, :postal_code, prices_attributes: [:id, :timeframe, :amount])
  end

end
