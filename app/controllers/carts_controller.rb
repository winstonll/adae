class CartsController < ApplicationController
	def index
		@items = Array.new
		# Search to see if this user already have existing items to checkout in the db
		if current_user
			session_to_cart = session[:cart] # Let's check our session to see if the user carted anything while not signed in.
			if !session_to_cart.nil? # If they did
				session_to_cart.each do |c| # Create each item in the session cart in the DB and attach to current user.
					if cart = Cart.find_by(user_id: current_user.id, item_id: c[1]["id"]) # Check if the item exists in DB
						cart.update(user_id: current_user.id, # If it did, update it
									item_id: c[1]["id"],
									name: c[1]["title"], 
			                      	price: c[1]["price"].to_f)
					else # else create it	
						Cart.create(user_id: current_user.id,
			                      item_id: c[1]["id"], 
			                      name: c[1]["title"], 
			                      price: c[1]["price"].to_f)
					end
				end
			end
			session[:cart] = nil
			@cartitems = Cart.where(user_id: current_user.id)
		else
			@cartitems = session[:cart]
		end

		if @cartitems == nil
		else
			@cartitems.to_a.each do |cart|
				if current_user
					@cartRecord = cart.item # cartitems are from cart.
				else # we got cart data from a session
					@cartRecord = Item.find_by_id(cart[0])
				end
				if @cartRecord # The cartitems are from session, check if the item is in the db
					@items << [@cartRecord, cart] # We can show it
				else 
					@items << [@cartRecord, cart] #This should not be here?
					if current_user #It was cart DB data
						Cart.destroy(cart.id) # Delete the item from the Cart DB attached to the user
					else
						session[:cart].delete(p["id"]) # Delete the item from the session
					end
				end 
			end
		end
	end

	def add
		# cart_item – try to find the item in the db if it exists
		if current_user
			cart_item = Cart.find_by(user_id: current_user.id, item_id: params[:item_id])
		end
		# It doesn't exist, and the user is logged on, create it for this user in the db.
		if cart_item.blank? && current_user
			cart_item = Cart.create(user_id: current_user.id,
									item_id: params[:item_id], 
									name: params[:title],
									price: params[:price])
		# It exists, and user is logged on, update it in the db.
		elsif cart_item && current_user
			cart_item.update(name: params[:title],
							price: params[:price])
		# The user is not logged on, so we use sessions
		else
			session[:cart] ||={}
			session[:cart][params[:item_id]] = {id: params[:item_id],
												title: params[:title],
												price: params[:price]
			}
		end
		render nothing:true
	end

	def destroy
		# Delete the item from the cart
		if current_user
			Cart.destroy(params[:id])
		else
			session[:cart].delete(params[:id])
		end
		redirect_to carts_path # Redirect to the shopping cart
	end

end
