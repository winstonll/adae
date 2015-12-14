class ApplicationController < ActionController::Base
  #include DeviseTokenAuth::Concerns::SetUserByToken
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || items_path
  end

  def after_sign_out_path_for(resource_or_scope)
   items_path
  end
  private

  def ensure_logged_in
   unless current_user
     flash[:alert] = "Please log in"
     session[:previous_url] = request.fullpath
     redirect_to new_session_path
   end
  end

end
