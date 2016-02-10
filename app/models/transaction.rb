class Transaction < ActiveRecord::Base
	has_many :StripeTransaction
	serialize :notification_params
end
