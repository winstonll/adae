class LocationsController < ApplicationController
	def edit
		
	end

	def update
		@user = current_user
		@location = Location.find_by(user_id: @user)
		if @location.update_attributes(location_params)
			redirect_to @user
			flash[:notice] = "Location saved"
		else
		  render :edit
	      flash[:warning] = "Location could not be updated"
	  end
	end
end

private

  def location_params
    params.require(:location).permit(:address, :city, :postal_code)
  end