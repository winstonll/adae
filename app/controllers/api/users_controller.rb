module Api
  class UsersController < ApplicationController
    # User name and password needed to access the users controller API and send
    # requests

    #http_basic_authenticate_with name: "admin", password: "Az2L%r[S";

    #use this to authenticate
    #include DeviseTokenAuth::Concerns::SetUserByToken
    #before_action :authenticate_user!


    # GET show all users
    def index
      @users = User.all
      render json: @users, status: :ok
    end

    # GET show specific user
    def show
      @user = User.where(id: params[:id]).first

      if !@user.nil?
        render json: @user
      else
        render json: {
          error: "No such user; check the user id",
          status: 400
        }, status: 400
      end
    end

    # DELETE destroy user and its association
    def destroy
      @user = User.where(id: params[:id])

      if !@user.empty?
        User.destroy(params[:id])
        head :no_content
      else
        render json: {
          error: "No such user; check the user id",
          status: 400
        }, status: 400
      end
    end

    private

      def user_params
        params.require(:user).permit(:name, :id)
      end

      def query_params
        params.permit(:name, :email)
      end

  end
end
