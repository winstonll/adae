class Users::RegistrationsController < Devise::RegistrationsController

  def create
    @user = User.new(user_params)
    @user.save
    @location = Location.new(user_id: @user.id, country: "CA", city: "Toronto")
    @location.save

    if @user.save
      session[:user_id] = @user.id
      redirect_to user_path(@user), notice: "Signed up!"
    else
      redirect_to :back
    end
  end

  private
    def user_params
      params.require(:user).permit(
        :name,
        :surname,
        :email,
        :password,
        location_attributes: [
          :city,
          :country
        ])
    end
end
