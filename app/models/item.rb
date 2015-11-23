class Item < ActiveRecord::Base
	validates :title, :description, :deposit, :tags,  presence: true
	
	belongs_to :user

	has_many :reviews, :dependent => :destroy
	has_many :ratings, :dependent => :destroy
	has_many :users_that_reviewed_this, through: :reviews, source: :user
	has_many :users_that_rated_this, through: :ratings, source: :user

	mount_uploader :image, ImageUploader

	def ratings_by_user(user)
		ratings.find_by(user: user).score
	end

	def total_score
		(self.ratings.sum(:score) / (5 * ratings.count(:user_id).to_f) * 100).round(0)
	end
end
