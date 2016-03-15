class TransactionsController < ApplicationController
	protect_from_forgery except: [:hook]
	before_action :signed_in_user, only: [:new, :edit, :update, :delete, :stripe, :stripe_success, :purchase_order]
	before_action :transaction_exists?, only: [:new]

	def new
		@transaction = Transaction.new
		@item = Item.find(params[:item_id])

    @prices = @item.prices
    @pictures = Picture.where(item_id: @item.id)

    @type_dropdown = []

    @prices.each do |price|
    	@type_dropdown.push([price.timeframe])
    end
	end

	def stripe
		Stripe.api_key = Rails.configuration.stripe[:secret_key]

		item = Item.where(id: params[:item_id]).first

		if !item.nil? && Transaction.where("(transactions.item_id = #{item.id} AND \
			transactions.buyer_id = #{current_user.id} AND \
			(transactions.status = ' Request Pending' OR transactions.status = 'Accepted' OR \
			transactions.status = 'In Progress'))").empty?

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
			seller_id: item.user_id, total_price: params[:price][1..params[:price].length - 1].to_f, length: item.listing_type == 'sell' ? nil : params[:duration])

			order_transaction.save

			if Conversation.between(current_user.id, seller.id).present?
				@conversation = Conversation.between(current_user.id,
				seller.id).first
			else
				@conversation = Conversation.create!(sender_id: current_user.id, recipient_id: seller.id)
			end

			redirect_to conversation_messages_path(@conversation, item_id: item.id)

		else
			redirect_to item_path(item.id)
		end
	end

	def destroy
		@transaction = Transaction.find(params[:id])

		@transaction.status = "Denied"
		@transaction.save

		redirect_to conversations_path
	end

	def cancel
		redirect_to conversations_path
	end

	def accept
		transaction = Transaction.find(params[:transaction])
		item = Item.find(params[:item_id])
		seller = User.find(transaction.seller_id)
		buyer = User.find(transaction.buyer_id)

		description = "#{seller.name}(#{seller.id}), #{item.listing_type}s, to #{current_user.name}(#{current_user.id})"

		@customer = Stripe::Customer.retrieve(buyer.stripe_customer_id)

		charge_price = (transaction.total_price.to_f * 100).ceil

		if params[:lease]
			sub_total = (markup_calculation(item.deposit) - transaction.total_price).to_f
			if buyer.balance > 0


				if buyer.balance > sub_total
					sub_total = 0
					buyer.balance = buyer.balance - subtotal
					buyer.save
				else
					sub_total = sub_total - buyer.balance
					buyer.balance = 0
					buyer.save
				end
			end

			charge_price = (sub_total * 100).ceil
		end

		# Charge the customer instead of the card
		begin
			charge = Stripe::Charge.create(
				:customer => @customer.id,
		    :amount => charge_price, # amount in cents, again
		    :currency => "cad",
		    :description => description
		  )

			rescue Stripe::CardError => e
				flash[:alert] = e.message
				redirect_to conversations_path
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

			if params[:lease]
				item.status = "Sold"
				item.save
				transaction.status = "Completed"
				transaction.save
				redirect_to conversations_path
			else
				transaction.status = "Accepted"
				transaction.save
				redirect_to :back
			end
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

		def markup_calculation(price)
			l1 = 1.1
			l2 = 1.08
			l3 = 1.06
			l4 = 1.04
			l5 = 1.02

			displayPrice = 0

	    if(price < 100)
	      displayPrice = (price * l1).round
	    elsif(price >= 100 && price < 200)
	      displayPrice = ((100 * l1) + (price - 100) * l2).round
	    elsif(price >= 200 && price < 500)
	      displayPrice = ((100 * l1) + (100 * l2) + ((price - 200) * l3)).round
	    elsif(price >= 500 && price < 1000)
	      displayPrice = ((100 * l1) + (100 * l2) + (300 * l3) + ((price - 500) * l4)).round
	    elsif(price >= 1000)
	      displayPrice = ((100 * l1) + (100 * l2) + (300 * l3) + (500 * l4) + ((price - 1000) * l5)).round
			end

			return displayPrice
		end

		def transaction_exists?
			@item = Item.find(params[:item_id])
			@item_validate = @item.user_id == current_user.id

			@transaction_validate = Transaction.where("((transactions.buyer_id = #{current_user.id}) \
			AND transactions.item_id = #{params[:item_id]} AND \
			(transactions.status = 'Request Pending' OR transactions.status = 'Accepted' OR \
			 transactions.status = 'In Progress'))").empty?

			if !@transaction_validate || @item_validate
				redirect_to items_path
			end
		end

		def transaction_params
		  params.require(:transaction).permit(:item_id, :buyer_id, :seller_id, :length, :status, :total_price)
		end

		def signed_in_user
	  	unless signed_in?
	      redirect_to request.referrer, flash: {warning: "Please sign in before you checkout.", signup_modal: true}
	  	end
	  end

end
