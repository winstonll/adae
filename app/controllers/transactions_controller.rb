class TransactionsController < ApplicationController
	protect_from_forgery except: [:hook]
	before_action :signed_in_user, only: [:index, :new, :edit, :update, :delete, :stripe, :stripe_success, :purchase_order]

	def index
		
	end

	def new
		@transaction = Transaction.new
		@item = Item.find(params[:item_id])
	    @prices = @item.prices
	    @pictures = Picture.where(item_id: @item.id)
	    @fee = ((@prices.first.amount * 0.029) + 0.30)
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
					:description => 'Purchase',
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
		# Only the purchaser can see this information
		if current_user.id == @order.buyer_id
			@purchase_items = @order.Transaction.all
			@notification_params_name = JSON.parse(@order.StripeTransaction.all[0][:notification_params])["source"]["name"]
			@contact = current_user
			invoice_details_hash = { order: @order,
				purchase_items: @purchase_items,
				notification_params: @notification_params_name,
				currency: "cad",
				billed_contact: @contact,
				adae_fee: @adae_fee
			}

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

	def purchase_order
		@order = Transaction.find_by(id:params[:id])
		# Only the purchaser can see this information
		if current_user.id == @order.buyer_id
			@purchase_items = Transaction.where(transaction_id: @order[:id])
			@notification_params_name = JSON.parse(@order.StripeTransaction.all[0][:notification_params])["source"]["name"]
			@contact = current_user
			respond_to do |format|
				format.html
				format.pdf do
					render pdf: "Invoice ##{@order.id}",
						template: "transactions/purchase_order.pdf.erb"
				end
			end
		else
			redirect_to root_path, flash: {warning: "You are not authorized to view this page."}
		end
	end

	private

	def transaction_params
	    params.require(:transaction).permit(:item_id, :buyer_id, :seller_id, :length, :status, :total_price)
	end

	# into transaction_items table with transaction_id
	def item_sold(order)

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
			item = Transaction.find_or_initialize_by(transaction_id: order.id, item_id: item.id) #Create the item
			item.update(order_item)
		end
	end

	# Calculates adae fee for one kind of item in a transaction
	def adae_fee(subtotal)
			adae_fee = ((subtotal * 0.029) + 0.30)
		return adae_fee.round(2).to_f # return the fee
	end

	def signed_in_user
    	unless signed_in?
        	redirect_to request.referrer, flash: {warning: "Please sign in before you checkout.", signup_modal: true}
    	end
    end

end
