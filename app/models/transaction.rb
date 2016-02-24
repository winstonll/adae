class Transaction < ActiveRecord::Base
	belongs_to :item
	has_many :StripeTransaction
	serialize :notification_params
end
