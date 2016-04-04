class ItemsController < ApplicationController
  before_action :ensure_logged_in, only: [:create, :update, :edit, :destroy]
  before_action :item_deleted?, only: [:show]

  def index
      @items = Item.where(status: "Listed").paginate(:page => params[:page], :per_page => 8).order('created_at DESC')

      gon.map_items = @items.pluck(:latitude, :longitude, :id, :title, :photo_url)

      respond_to do |format|
        format.html #{ render :template => '/products_home.html.erb' }
        format.js  # Prodcuts home partial
      end
  end

  def show
    @item = Item.find(params[:id])
    gon.map_item = Item.where(id: @item.id).pluck(:latitude, :longitude, :id)
    @review = @item.reviews.build
    @prices = []

    if ['sell', 'timeoffer'].include?(@item.listing_type)
      @prices = @item.prices
    else
      if price = @item.prices.where(timeframe: "Day").first
        @prices.push(price)
      end

      if price = @item.prices.where(timeframe: "Week").first
        @prices.push(price)
      end

      if price = @item.prices.where(timeframe: "Month").first
        @prices.push(price)
      end
    end

    @pictures = Picture.where(item_id: @item.id)
    if user_signed_in?
      @transaction_dne = Transaction.where(" (transactions.status != 'Completed' AND transactions.status != 'Denied'\
      AND transactions.status != 'Pending') AND (transactions.item_id = #{@item.id})").empty?

      @listing_avail = @transaction_dne || !@item.listing_type == "sell" || @item.listing_type == "timeoffer" || @item.listing_type == "lease" || @item.listing_type == "rent"

      @reviewable = Transaction.where("(transactions.buyer_id = #{current_user.id}) \
      AND (transactions.status = 'Completed') AND (transactions.item_id = #{@item.id})").empty?
    else
      @transaction_dne = false
      @reviewable = false
    end

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

  def discount
    if user_signed_in? && Share.where(user_id: current_user.id, item_id: params[:item_id]).empty?
      share = Share.new()
      share.user_id = current_user.id
      share.item_id = params[:item_id].to_i

      share.save
    end

    render :nothing => true
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
    if user_signed_in? && current_user.id == @item.user_id
      @tags = @item.tags.split(',')
      @prices = @item.prices
    else
      redirect_to items_path
    end
  end

  def update

    @item = Item.find(params[:id])

    7.times do |count|
      counter = "tag_box_#{count}".to_sym
      unless (params[counter].to_s.empty?)
        @tagboxes = @tagboxes.to_s + params[counter].to_s.capitalize.strip << ', '
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

    if ["rent", "lease"].include?(@item.listing_type) && @item.update_attributes(item_edit_params)
      update_prices

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
    elsif ["sell", "timeoffer"].include?(@item.listing_type) && @item.update_attributes(item_params)
      redirect_to @item, notice: "Item Successfully Edited!"
    else
      redirect_to :back, flash: {error: true}
    end
  end

  def destroy
    @item = Item.find(params[:id])
    @item.status = "Deleted"
    @item.save
    redirect_to user_path(current_user)
  end

  private

    def item_deleted?
      item = Item.find(params[:id])

      unless ["Listed", "Sold"].include?(item.status)
        redirect_to items_path
      end
    end

    def update_prices
      params[:item][:prices_attributes].each do |price|
        item_price = @item.prices.where(timeframe: price[1][:timeframe]).first
        if !item_price.nil?
          if price[1][:timeframe] == "Day" || price[1][:timeframe] == "Hour"
            if params[:item][:prices_attributes]["0"][:amount].to_f == 0
              item_price.delete
            else
              item_price.amount = params[:item][:prices_attributes]["0"][:amount].to_f
              item_price.save
            end
          elsif price[1][:timeframe] == "Week"
            if params[:item][:prices_attributes]["1"][:amount].to_f == 0
              item_price.delete
            else
              item_price.amount = params[:item][:prices_attributes]["1"][:amount].to_f
              item_price.save
            end
          elsif price[1][:timeframe] == "Month"
            if params[:item][:prices_attributes]["2"][:amount].to_f == 0
              item_price.delete
            else
              item_price.amount = params[:item][:prices_attributes]["2"][:amount].to_f
              item_price.save
            end
          end
        else
          item_price = Price.new
          if price[1][:timeframe] == "Day" || price[1][:timeframe] == "Hour"
            if params[:item][:prices_attributes]["0"][:amount].to_f != 0
              item_price.timeframe = price[1][:timeframe]
              item_price.item_id = @item.id
              item_price.amount = params[:item][:prices_attributes]["0"][:amount].to_f
              item_price.save
            end
          elsif price[1][:timeframe] == "Week"
            if params[:item][:prices_attributes]["1"][:amount].to_f != 0
              item_price.timeframe = price[1][:timeframe]
              item_price.item_id = @item.id
              item_price.amount = params[:item][:prices_attributes]["1"][:amount].to_f
              item_price.save
            end
          elsif price[1][:timeframe] == "Month"
            if params[:item][:prices_attributes]["2"][:amount].to_f != 0
              item_price.timeframe = price[1][:timeframe]
              item_price.item_id = @item.id
              item_price.amount = params[:item][:prices_attributes]["2"][:amount].to_f
              item_price.save
            end
          end
        end
      end
    end

    def item_params
      params.require(:item).permit(:title, :photo, :description, :image, :user_id, :listing_type, :deposit, :tags, :postal_code, prices_attributes: [:id, :timeframe, :amount])
    end

    def item_edit_params
      params.require(:item).permit(:title, :photo, :description, :image, :user_id, :listing_type, :deposit, :postal_code)
    end

end
