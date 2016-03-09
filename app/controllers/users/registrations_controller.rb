class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_sign_up_params, only: [:create]

  def create
    @user = User.new(user_params)
    @user.save

    @referral = Referral.new()

    loop do
      @code=SecureRandom.hex(8).upcase
      [4,9,14].each do |f|
        r.insert(f, "-")
      end
			break @referral.code = @code unless Referral.where(code: @code).first
		end

    @referral.amount = 5.00
    @referral.user_id = @user.id
    @referral.save

    @location = Location.new(user_id: @user.id, country: "CA", city: "Toronto")
    @location.save

    if @user.save
      session[:user_id] = @user.id
      redirect_to items_path, notice: "Signed up! Check your email address to confirm your account!"
    else
      redirect_to :back, notice: "This account is already taken"
    end
  end

  private

    def user_params
      params.require(:user).permit(
        :name,
        :surname,
        :email,
        :password,
        :avatar,
        location_attributes: [
          :city,
          :country
        ])
    end

  protected

  def after_sign_up_path_for(resource)
    signed_in_root_path(resource)
  end

  def after_update_path_for(resource)
    signed_in_root_path(resource)
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name, :email, :password, :password_confirmation)}
  end
end
