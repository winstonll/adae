class StripeController < ApplicationController
	# Create a manage Stripe account for yourself.
  	# Only works on the currently logged in user.
  	# See app/services/stripe_managed.rb for details.
  	def managed
    	connector = StripeManaged.new( current_user )
    	account = connector.create_account!(
      		params[:country], params[:tos] == '1', request.remote_ip
    	)

    	if account
      		flash[:success] = "Managed Stripe account created!"
    	else
      		flash[:danger] = "Unable to create Stripe account!"
    	end
    	redirect_to users_stripe_settings_path 
  	end
end
