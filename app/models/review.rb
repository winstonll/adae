class Review < ActiveRecord::Base
	belongs_to :user
	belongs_to :item
	validates :comment,  presence: true 
end
