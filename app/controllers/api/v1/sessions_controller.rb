module Api::V1
  class SessionsController < ApplicationController
    # User name and password needed to access the users controller API and send
    # requests

    #http_basic_authenticate_with name: "admin", password: "Az2L%r[S";

    #use this to authenticate
    #include DeviseTokenAuth::Concerns::SetUserByToken
    #before_action :authenticate_user!

    # GET show all users
    def index

    end

    # GET show specific user
    def show

    end

    # curl -i -X POST -d 'users[email]=test2@hotmail.com&user[password]=12345678' http://localhost:3000/api/users
    def create

    end

    # DELETE destroy user and its association
    def destroy

    end

    private

      def session_params
        params.require(:sessions).permit(:email, :password, :uid, :password_confirmation, :auth_token)
      end

  end
end
