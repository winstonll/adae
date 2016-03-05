class TransactionsController < ApplicationController
	protect_from_forgery except: [:hook]
	before_action :signed_in_user, only: [:new, :edit, :update, :delete, :stripe, :stripe_success, :purchase_order]

	def new
		@transaction = Transaction.new
		@item = Item.find(params[:item_id])
	    @prices = @item.prices
	    @pictures = Picture.where(item_id: @item.id)
	    @fee = ((@prices.first.amount * 0.029) + 0.30)
	end

	def stripe
		Stripe.api_key = Rails.configuration.stripe[:secret_key]

		item = Item.where(id: params[:item]).first

		if !item.nil?

			if current_user.stripe_customer_id.nil?
				@customer = Stripe::Customer.create(
					:email => params[:stripeEmail],
					:source => params[:stripeToken]
				)
				current_user.stripe_customer_id = @customer.id
				current_user.save
			end

			seller = User.where(id: item.user_id).first

			order_transaction = Transaction.new(item_id: item.id, buyer_id: current_user.id,
			seller_id: item.user_id, total_price: params[:price].to_f, length: item.listing_type == 'sell' ? nil : params[:duration])

			order_transaction.save

			if Conversation.between(current_user.id, seller.id).present?
				@conversation = Conversation.between(current_user.id,
				seller.id).first
			else
				@conversation = Conversation.create!(sender_id: current_user.id, recipient_id: seller.id)
			end

			redirect_to conversation_messages_path(@conversation)

		else
			redirect_to :back
		end
	end

	def transaction_accepted

		description = "#{seller.name}(#{seller.id}), #{item.listing_type}s, to #{current_user.name}(#{current_user.id})"

		# Charge the customer instead of the card
		begin
			charge = Stripe::Charge.create(
				:customer => @customer.id,
		    :amount => (params[:price].to_f * 100).ceil, # amount in cents, again
		    :currency => "cad",
		    :description => description
		  )

			rescue Stripe::CardError => e
				flash[:alert] = e.message
				redirect_to new_transaction_path
		end

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

			@sT = StripeTransaction.create(stripeCharge) # make a record in the StripeTransactions table
		end
	end

	# Grabs all the necessary data and presents an invoice display page after purchases
	def stripe_success
		@order = Transaction.find(params[:id])
		@item = Item.where(id: @order.id).first
		@total_amount = ((@order.total_price - 0.3) / 1.029)
		@adae_fee = @order.total_price - @total_amount
		@length = @order.length.split('-')[1]
		@length = @length[0..@length.length - 2]
		@price = @item.prices.where(timeframe: @length).first

		# Only the purchaser can see this information
		if current_user.id == @order.buyer_id
=begin
			@contact = current_user

			invoice_details_hash = { order: @order,
				purchase_items: @purchase_items,
				notification_params: @notification_params_name,
				currency: "cad",
				billed_contact: @contact,
				adae_fee: @adae_fee
			}
=end

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

	def signed_in_user
    	unless signed_in?
        	redirect_to request.referrer, flash: {warning: "Please sign in before you checkout.", signup_modal: true}
    	end
    end

end
