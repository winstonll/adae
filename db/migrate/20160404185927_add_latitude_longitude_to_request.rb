class AddLatitudeLongitudeToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :latitude, :float, :default => 43.6617
    add_column :requests, :longitude, :float, :default => -79.3950
    add_column :requests, :created_at, :datetime
    add_column :requests, :updated_at, :datetime
  end
end
