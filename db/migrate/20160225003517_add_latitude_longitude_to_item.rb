class AddLatitudeLongitudeToItem < ActiveRecord::Migration
  def change
    add_column :items, :latitude, :float, :default => 43.6617
    add_column :items, :longitude, :float, :default => -79.3950
  end
end
