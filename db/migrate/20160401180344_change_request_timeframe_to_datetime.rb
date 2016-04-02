class ChangeRequestTimeframeToDatetime < ActiveRecord::Migration
  def change
  	change_column :requests, :timeframe, :datetime
  end
end
