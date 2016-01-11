class FixTypeColumnName < ActiveRecord::Migration
  def change
  	rename_column :items, :type, :listing_type
  end
end
