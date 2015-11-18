class Rating < ActiveRecord::Base
	validates :score,  presence: true
	
	belongs_to :user
	belongs_to :item

	# def average_rating_by_user
	# 	((1_rating + 2_rating + 3_rating + 4_rating + 5_rating) / 20.0) * 100
	# end
end
