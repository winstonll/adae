class Users::SessionsController < ApplicationController
	skip_before_filter :require_login

  def create
  	user = User.find_by(email: params[:email])
  		if user && user.authenticate(params[:password])
        session[:user_id] = user.id
        default_url = (session.delete(:previous_url) || root_path)
  			redirect_to default_url, :notice => "Logged in!"
  		else
      	render "new"
    	end
  end

  def destroy
		user = User.find(session[:user_id])
		sign_out user
    redirect_to items_url, notice: "Logged out!"
  end

end
