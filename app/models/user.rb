class User < ActiveRecord::Base
	has_secure_password
	has_many :reviews
	has_many :ratings
	has_many :items
  	has_many :items_reviewed, through: :reviews, source: :items
  	has_many :items_rated, through: :ratings, source: :items
  	validates :first_name, :last_name, :phone_number,  presence: true


  	def full_name
  		"#{first_name} #{last_name}"
  	end

	def rated?(item)
		ratings.find_by(item: item)
	end
end
