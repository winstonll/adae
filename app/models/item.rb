class Item < ActiveRecord::Base
	validates :title, :description, :deposit, :tags,  presence: true
	
	belongs_to :user

	has_many :reviews, :dependent => :destroy
	has_many :ratings, :dependent => :destroy
	has_many :users_that_reviewed_this, through: :reviews, source: :user
	has_many :users_that_rated_this, through: :ratings, source: :user

	mount_uploader :image, ImageUploader

	 def ratings_by_user(user)
	 	rating = ratings.find_by(user: user)
	# 	rating.average_rating_by_user
	 end

	 def score
	 	(self.ratings.count(:user_id).to_f / 100).round(0)
	 end
	# def overall_rating 
	# 	(self.ratings.sum("1_rating + 2_rating + 3_rating + 4_rating + 5_rating ") / (20 * ratings.count(:user_id).to_f) * 100).round(0)
	# end
end
