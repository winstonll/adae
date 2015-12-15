class SessionsController < Devise::SessionsController
  skip_before_filter :require_login

  def create
  	asd
  end

  def destroy
		asd
  end

end
