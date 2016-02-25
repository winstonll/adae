class TransactionsController < ApplicationController
	protect_from_forgery except: [:hook]
	before_action :signed_in_user, only: [:index, :new, :create, :edit, :update, :delete, :stripe, :stripe_success, :purchase_order]

	def index
		@cart = Cart.where(user_id: current_user.id) #Grab whatever is in the cart
		if @cart.empty? # If there is nothing attached to this user
			@cart = session[:cart] # See if there's anything in the session.
			session[:cart] = nil # Empty out the session
			if !@cart.nil? # If the cart is not empty
				@cart.each do |c| # Create each item in the session cart in the DB and attach to current user.
					Cart.create(user_id: current_user.id,
								item_id: c[1]["id"],
								name: c[1]["title"],
								price: c[1]["price"].to_f)
				end 
			end
		end
		@fee = total_adae_fee
		@cart = Cart.where(user_id: current_user.id) # Just in case we removed anything during our sanitization period with stripe_vendor_charges
		@subtotal = get_subtotal(@cart) # Calculate the total for it
	end

	def new
		@transaction = Transaction.new
		@item = Item.find(params[:item_id])
	    @price = Price.where(item_id: @item.id).first
	    @pictures = Picture.where(item_id: @item.id)
	end

	def create
		@transaction = Transaction.create(transaction_params)
		@transaction.buyer_id = current_user 

	end

	def stripe
		billing = {
			name: params["stripeBillingName"],
			address: {
				line1: params["stripeBillingAddressLine1"],
				postal_code: params["stripeBillingAddressZip"],
				city: params["stripeBillingAddressCity"],
				region: params["stripeBillingAddressState"],
				country: params["stripeBillingAddressCountryCode"],
			}	
		}

		Stripe.api_key = Rails.configuration.stripe[:secret_key]

		@customer = Stripe::Customer.create(
			:email => params[:stripeEmail],
			:source => params[:stripeToken]
		)
		stripeTransactions = Array.new # Array used so later we can update the StripeTransactions with their Transaction id
		amount_total = 0 # Keep track of the total
		session[:svc].each do |key, array|
			token = Stripe::Token.create({:customer => @customer.id}, {:stripe_account => array['stripe_id']})

			# Charge the customer instead of the card
			charge = Stripe::Charge.create(
				{  	:source 	=> token.id,
					:amount 	=> (array['total']*100).to_i,
					:description => 'Cart Purchase',
					:currency => "cad",
					:application_fee => (array['fee']*100).to_i
				}, {:stripe_account => array['stripe_id']}
			)

			# If the charge succeeded, then record the data
			if charge[:paid]
				stripeCharge = {
					txn_type: charge[:object],
					currency: charge[:currency],
					total_amount: charge[:amount],
					notification_params: charge,
					txn_id: charge[:id],
					status: charge[:paid],
					description: charge[:description] 
				}
				amount_total = amount_total + (array['total']*100).to_i # Keep track of the total
				@sT = StripeTransaction.create(stripeCharge) # make a record in the StripeTransactions table
				fasdfljksda
				stripeTransactions << @sT.id # push the id into the stripeTransactions array for later use
			end
		end


		if !stripeTransactions.empty? # If our stripeTransactions array is not empty, we made some transactions
			@orderInfo = { # Gather the following information
				buyer_id: current_user.id,
				purchased_at: Time.now,
				total_amount: amount_total,
			}
			@order = Transaction.create(@orderInfo)
			StripeTransaction.where(id:stripeTransactions).update_all(transaction_id: @order.id) #Update all the records of stripeTransactions with transaction_id: @order.id
			transaction_fee = {
				fee_amount: total_adae_fee, #get the fees of all stripe_transcactions for this order
				transaction_id: @order.id
			}
			@transaction_fee = TransactionFee.create(transaction_fee)
		end

			item_sold(@order)
			session.delete(:svc) # Clean up sessions
			redirect_to action: "stripe_success", id: @order.id
		
		rescue Stripe::CardError => expiry_date
			flash[:error] = e.message
			redirect_to transaction_path
	end

	# Grabs all the necessary data and presents an invoice display page after purchases
	def stripe_success
		@order = Transaction.find(params[:id])
		@adae_fee = TransactionFee.where(transaction_id: @order.id).first
		# Only the purchaser can see this information
		if current_user.id == @order.buyer_id
			@purchase_items = @order.TransactionItem.all
			@notification_params_name = JSON.parse(@order.StripeTransaction.all[0][:notification_params])["source"]["name"]
			@contact = current_user
			invoice_details_hash = { order: @order,
				purchase_items: @purchase_items,
				notification_params: @notification_params_name,
				currency: "cad",
				billed_contact: @contact,
				adae_fee: @adae_fee
			}

			Cart.destroy_all(user_id: current_user.id)
			# InvoiceMailer.invoice_details(invoice_details_hash).deliver_now
			# respond_to do |format|
			# 	format.html
			# 	format.pdf do 
			# 		render pdf: "Invoice ##{@order.id}",
			# 			template: "transactions/purchase_order.pdf.erb"
			# 	end
			# end
		else
			redirect_to root_path, flash: {warning: "You are not authorized to view this page."}
		end
	end

	# For sidebar use, to list all the personal purchases made by user
	def list_personal_purchases
		@purchases = Transaction.where(buyer_id:current_user.id).to_a
	end

	# def purchase_order
	# 	@order = Transaction.find_by(id:params[:id])
	# 	@adae_fee = TransactionFee.find_by_id(@order.transaction_fee_id)
	# 	# Only the purchaser can see this information
	# 	if current_user.id == @order.buyer_id
	# 		@purchase_items = TransactionItem.where(transaction_id: @order[:id])
	# 		@notification_params_name = JSON.parse(@order.StripeTransaction.all[0][:notification_params])["source"]["name"]
	# 		@contact = current_user
	# 		# respond_to do |format|
	# 		# 	format.html
	# 		# 	format.pdf do
	# 		# 		render pdf: "Invoice ##{@order.id}",
	# 		# 			template: "transactions/purchase_order.pdf.erb"
	# 		# 	end
	# 		end
	# 	else
	# 		redirect_to root_path, flash: {warning: "You are not authorized to view this page."}
	# 	end
	# end

	private

	def transaction_params
	    params.require(:transaction).permit(:item_id, :buyer_id, :seller_id, :length, :status, :total_price)
	end

	# into transaction_items table with transaction_id
	def item_sold(order)
		@cart_item = Cart.where(user_id: current_user.id)  # Grab whatever is in the cart
		array = Array.new  # Make a new array for holding ids
		@cart_items.each do |id| 
			array << id[:item_id].to_i
		end

		@items = Item.where(id:array) # Find all the items with the id array
		# For each item
		@items.each_with_index do |item, index|

			q = @cart_items.find{ |cart| cart.item_id == item.id}
			item.save
			# Create the hash for insert into transaction_items
			order_item = {
				title: item.title,
				description: item.description,
				price: item.prices.collect(&:amount).flatten.uniq,
				image: item.image,
				item_id: item.id,
				transaction_id: order.id, 
			}
			item = TransactionItem.find_or_initialize_by(transaction_id: order.id, item_id: item.id) #Create the item
			item.update(order_item)
		end
	end

	# Get subtotal, grabs the total of the cart and sanitizes the session variables
	def get_subtotal(cart_array)
		@cart = price_session_sanitization(cart_array)
		@total = 0
		if @cart.blank? # do nothing
		else # Add the price of each item to the running total
			@cart.each do |price| 
	            @total = @total + (price["price"].to_f)
	        end
	    end
	    return @total # return the subtotal
	end

	def price_session_sanitization(cart_array)
		# Check if we have a cart_array passed in, if we do, use that, if not, then do a DB call
		if cart_array.empty?
			@cart = Cart.where(user_id: current_user.id) # Grab whatever is in the cart
		else
			@cart = cart_array
		end
		array = Array.new # Make a new array for sanitization
		# Go through the cart and collect the ids of each item, so we can get the price from the DB
		# to ensure that session variables like price were not manipualted
		@cart.each do |id|
			array << id[0].to_i
		end
		@items = Item.where(id:array) # Select the items from the ids
		# Each item, grab the price from the db and assign to @cart variable
		@items.each do |item|
			@cart[item.id.to_s]["price"] = item["price"].to_s
		end
		return @cart
	end

	# Calcuales total adae fee for all items in a transaction
	def total_adae_fee
		session[:svc] = stripe_vendor_charges # Might as well set the session
		fee = 0
		session[:svc].each do |key, array|
			fee = fee + array[:fee]
		end
		return fee
	end

	# This function breaks down our cart and tallies up the total according to vendor
	# It returns an array [stripe_user_id, total]
	def stripe_vendor_charges
		@cart_items = Cart.where(user_id: current_user.id)  # Grab whatever is in the cart
		array = Array.new  # Make a new array for holding ids
		@cart_items.each do |id| # Throw all id's into the array
			array << id[:item_id].to_i
		end
		@items = Item.where(id:array) # Find all the items with the id array

		h = Hash.new  # Make a new hash for holding ids
		@items.each do |item|
			# We need to find the COO, to get his stripe_user_id
			person = User.where.not(stripe_user_id: nil)
			c = @cart_items.find{ |cart| cart.item_id == item.id } # This is to match the item to the cart item to get "c"

			if !person.empty?
				c = @cart_items.find{ |cart| cart.item_id == item.id } # This is to match the item to the cart item to get "c"
				subtotal = c.price # calculate subtotal
				fee = adae_fee(subtotal, item) #calculate the adae fee
				if !h[person[0][:stripe_user_id]].blank? # If the stripe_user_id already existed (i.e. selling 2 different items by same vendor)
					h[person[0][:stripe_user_id]] = {total: (h[person[0][:stripe_user_id]][:total] + (subtotal+fee)).round(2).to_f,
													fee: (h[person[0][:stripe_user_id]][:fee] + fee).round(2).to_f,
													stripe_id: person[0][:stripe_user_id]
										}
				else # first item being sold by vendor, add the vendor to the list
					h[person[0][:stripe_user_id]] = { total: 0 + (subtotal).round(2).to_f, 
													  fee: fee.round(2).to_f,
													  stripe_id: person[0][:stripe_user_id]
										}
				end
			else
				Cart.destroy(c.id)
				flash[:warning] = "One or more of the items checked out have been removed because orders are not being taken for those items at the moment."
			end
		end
		return h
	end

	# Calculates adae fee for one kind of item in a transaction
	def adae_fee(subtotal, item)
			adae_fee = subtotal * 0.05
		return adae_fee.round(2).to_f # return the fee
	end

	def signed_in_user
    	unless signed_in?
        	store_location
        	redirect_to new_user_session_path, flash: {warning: "Please sign in before you checkout."}
    	end
    end

end
