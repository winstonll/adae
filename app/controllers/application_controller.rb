class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery

  # rescue_from CanCan::AccessDenied do |exception|
  #   redirect_to root_url, :alert => exception.message
  # end

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
    rescue ActiveRecord::RecordNotFound
  end

  helper_method :current_user

  def ensure_logged_in
    unless current_user
      flash[:alert] = "Please log in"
      session[:previous_url] = request.fullpath
      redirect_to new_session_path
    end
  end

  def require_user
    redirect_to root_path unless current_user
  end
end
