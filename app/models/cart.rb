class Cart < ActiveRecord::Base
	has_one :user
	belongs_to :item
	validates :name, presence: true
	validates :price, presence: true, numericality: true

end
