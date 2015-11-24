class RemoveLocationColumnsFromUsers < ActiveRecord::Migration
	def change
		remove_column :users, :address_line1
		remove_column :users, :city
		remove_column :users, :postal_code
	end
end
