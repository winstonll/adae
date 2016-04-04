class ChangeRequestTimeframeToDatetime < ActiveRecord::Migration
  def up
    remove_column :requests, :timeframe
    add_column :requests, :timeframe, :datetime
  end

  def down
    remove_column :requests, :timeframe
    add_column :requests, :timeframe, :time
  end
end


  
