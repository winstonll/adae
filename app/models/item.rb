class Item < ActiveRecord::Base
	validates :title, :description, :user_id, :deposit, :rent2buy, :tags, :image,  presence: true
	
	belongs_to :user

	has_many :reviews, :dependent => :destroy
	has_many :ratings, :dependent => :destroy
	has_many :users_that_reviewed_this, through: :reviews, source: :user
	has_many :users_that_rated_this, through: :ratings, source: :user

	#mount_uploader :image, ImageUploader

	# def ratings_by_user(user)
	# 	rating = ratings.find_by(user: user)
	# 	rating.average_rating_by_user
	# end


	# def overall_rating 
	# 	(self.ratings.sum("knowledge_rating + support_rating + comfort_rating + accessibility_rating + recommendation_rating ") / (20 * ratings.count(:user_id).to_f) * 100).round(0)
	# end
end
