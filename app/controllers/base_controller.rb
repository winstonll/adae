class BaseController < ActionController::Base
  #include DeviseTokenAuth::Concerns::SetUserByToken
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  include Authenticable

  # rescue_from CanCan::AccessDenied do |exception|
  #   redirect_to root_url, :alert => exception.message
  # end

  private

  #def current_user
  #  @current_user ||= User.find(session[:user_id]) if session[:user_id]
  #  rescue ActiveRecord::RecordNotFound
  #end

  #helper_method :current_user

  #def require_user
  #  redirect_to root_path unless current_user
  #end
end
