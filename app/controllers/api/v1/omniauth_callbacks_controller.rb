module Api::V1
  class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

    def facebook

      # You need to implement the method below in your model (e.g. app/models/user.rb)
      @user = User.from_omniauth(request.env["omniauth.auth"])

      if @user.persisted?
        render json: @user, status: 200
      else
        render json: { errors: "This account already exists" }, status: 422
      end
    end

    def failure
      redirect_to root_path
    end

  end
end
