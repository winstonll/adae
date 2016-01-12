class Request < ActiveRecord::Base
	validates :title, :description, :user_id, :tags, :timeframe, :postal_code,  presence: true
	validates :title, :description, :postal_code,  uniqueness: true
	
	belongs_to :user
end
