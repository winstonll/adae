class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  #include DeviseTokenAuth::Concerns::SetUserByToken
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    root_path
  end

  def after_sign_out_path_for(resource_or_scope)
   root_path
  end

  private
  def ensure_logged_in
   unless current_user
     flash[:warning] = "Please Log in or Sign up!"
     session[:previous_url] = request.fullpath
      redirect_to request.referrer
   end
  end

  protected

  # To permit new custom attributes to be verified as attributes permitted by the form
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit( :email, :password, :password_confirmation)}
  end

end
