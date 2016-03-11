class Location < ActiveRecord::Base
	belongs_to :user

	def full_address
		"#{address} #{city} #{postal_code}"
	end

end
