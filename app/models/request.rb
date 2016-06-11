class Request < ActiveRecord::Base
	validates :title, :description, :user_id, :timeframe, :tags, :postal_code,  presence: true
	validates :title, :description, uniqueness: true
	
	belongs_to :user
end
