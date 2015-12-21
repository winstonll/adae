module Authenticable

  # Devise methods overwrites
  def current_user
    @current_user ||= User.find_by(auth_token: request.headers['Authorization'])
  end

  def authenticate_user_token!
    render json: { errors: "Not authenticated" },
                status: :unauthorized unless user_signed_in?
  end

  def user_signed_in?
    current_user.present?
  end

  def authenticate_api
    #puts request.headers['Authorization']
    #puts request.headers['Auth_token']
    api_key = request.headers['ApiToken']

    @user = User.where(auth_token: api_key).first if api_key

    unless @user
      render json: { errors: "Invalid API access token" }, status: 422
      return false
    end
  end
end
