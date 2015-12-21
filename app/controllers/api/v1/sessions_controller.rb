module Api::V1
  class SessionsController < BaseController
    #use this to authenticate
    #include DeviseTokenAuth::Concerns::SetUserByToken
    #before_action :authenticate_user!

    # GET show all users
    def index

    end

    # GET show specific user
    def show

    end

    # curl -X POST -d 'sessions[email]=testing@hotmail.com&sessions[password]=1234567890' http://localhost:3000/api/v1/sessions
    def create
      user_password = params[:sessions][:password]
      user_email = params[:sessions][:email]

      user = user_email.present? && User.find_by(email: user_email)

      if user.valid_password? user_password

        #sign_in user, bypass: true
        sign_in user, store: false

        user.generate_authentication_token
        user.save
        render json: user, status: 200#, location: [:api, user]
      else
        render json: { errors: "Invalid email or password" }, status: 422
      end
    end

    # DELETE destroy user and its association
    def destroy
      user = User.find_by(auth_token: params[:id])
      user.generate_authentication_token
      user.save
      head 204
    end

    private

      def session_params
        params.require(:sessions).permit(:email, :password, :password_confirmation, :auth_token)
      end

  end
end
