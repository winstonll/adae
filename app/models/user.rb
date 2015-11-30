class User < ActiveRecord::Base
	has_many :reviews
	has_many :ratings
	has_many :items
  	has_many :items_reviewed, through: :reviews, source: :items
  	has_many :items_rated, through: :ratings, source: :items
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable, :omniauthable

  include DeviseTokenAuth::Concerns::User

  	def full_name
  		"#{name} #{surname}"
  	end

	def rated?(item)
		ratings.find_by(item: item)
	end

end
