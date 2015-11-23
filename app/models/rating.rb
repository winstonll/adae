class Rating < ActiveRecord::Base
	validates :score,  presence: true
	
	belongs_to :user
	belongs_to :item

end
