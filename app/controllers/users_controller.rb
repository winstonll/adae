class UsersController < ApplicationController
	before_filter :load_user, only:[:show, :edit, :update, :destroy]
	#before_filter :authenticate_user!
	before_action :signed_in_user, only: [:edit, :update, :stripe_settings]
  	before_action :correct_user,   only: [:edit, :update]

 	def show
 	  @user = User.find(params[:id])
 	  @items = @user.items.where(status: "Listed")
 	  @location = Location.find_by(user_id: @user) ? Location.find_by(user_id: @user) : Location.new()
 	  @transactions = Transaction.where("(transactions.seller_id = #{@user.id})")
 	  @requests = Transaction.where("(transactions.buyer_id = #{@user.id})")
 	  @referral = Referral.find_by(user_id: @user.id)
 	end

 	def edit
 		@user = User.find(params[:id])
 	end

 	def update
 	  if @user.update_attributes(user_params)
			sign_in(@user, :bypass => true)
			flash[:notice] = "Profile updated"
 	  	redirect_to @user
 	  else
 	  	render :edit
 	  end
 	end

 	def destroy
 	  @user.destroy
 	  redirect_to root_path, notice: "User account deleted!"
 	end

 	# This connects the company to a bank account in their country, only accessible by the COO
	def stripe_settings
		@manager = StripeManaged.new(current_user)
		if !current_user.stripe_account_status.nil?
			@charges = [ 'Charges', current_user.stripe_account_status['charges_enabled'] ]
			@transfers = [ 'Transfers', current_user.stripe_account_status['transfers_enabled'] ]
			@dob = @manager.legal_entity.dob
			@date_selected = Date.new(@dob.year, @dob.month, @dob.day) rescue nil
		end
	end
	# This updates the necessary information required by stripe
	def stripe_update_settings
		manager = current_user.manager
		manager.update_account! params: params
		redirect_to users_stripe_settings_path
	end

 	private

	 	def user_params
	 	  params.require(:user).permit(:name, :avatar, :surname, :email, :password, :password_confirmation,
	 	  :phone_number, :avatar)
	 	end

	 	def load_user
	 	  @user = User.find(params[:id])
	 	end

		# Before filters
	  def signed_in_user
	    unless signed_in?
	      store_location
	      redirect_to new_user_session_path, flash: {warning: "Please sign in."}
	    end
	  end

	  # Checks to see if the current user is actually the user this page is suppose to show
		# We don't want a person to type in the user of someone else in the link and edit their info
	  def correct_user
	    @user = User.find_by_id(params[:id])
	    if !@user.nil? && (current_user.id == @user.id) #If user is found, go to edit page, else go to sign in
	    else
	      flash[:danger] = "The request cannot be fulfilled."
	      redirect_to(new_user_session_path)
	    end
	  end

end
