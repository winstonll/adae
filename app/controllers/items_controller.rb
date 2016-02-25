class ItemsController < ApplicationController
  before_filter :ensure_logged_in, only: [:create, :update, :edit, :destroy]
  def index
      @items = Item.all
  end

  def show
    @item = Item.find(params[:id])
    @review = @item.reviews.build
    @price = Price.where(item_id: @item.id).first
    @pictures = Picture.where(item_id: @item.id)

      if current_user
       @rating = current_user.ratings.find_by(:item => @item)
       @cart = Cart.where(user_id: current_user.id, item_id: @item.id)
        if @cart.empty?
          @cart ||= session[:cart][@item.id.to_s] # Check whether we saved a session variable for this item
          if !@cart.empty? # There was a session variable for this item, attach it to this users cart
            Cart.create(user_id: current_user.id,
              item_id: @cart["id"],
              name: @cart["title"],
              price: @cart["price"].to_f)
            session[:cart][@item.id.to_s] = nil # Clean out the session cart
          end
        end
      else
      @cart ||= session[:cart]
        if @cart.nil? # This makes sure that @cart is a hash no matter what
          @cart = Hash.new # The template needs a hash or it'll throw an error.
        end
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

    @item.latitude = geocode.latitude
    @item.longitude = geocode.longitude
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
      flash[:message] = "This listing has already been posted or Something didn't validate"
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
    redirect_to user_path(current_user)
  end

  private

  def item_params
    params.require(:item).permit(:title, :photo, :description, :image, :user_id, :listing_type, :deposit, :tags, :postal_code, prices_attributes: [:id, :timeframe, :amount])
  end

end
