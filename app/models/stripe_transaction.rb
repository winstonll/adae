class StripeTransaction < ActiveRecord::Base
	belongs_to :Transaction, foreign_key: "transaction_id"
end