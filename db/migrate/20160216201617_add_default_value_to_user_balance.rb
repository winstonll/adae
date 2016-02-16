class AddDefaultValueToUserBalance < ActiveRecord::Migration
  def change
      change_column :users, :balance, :decimal, :default => 0.00, :precision => 10, :scale => 2
  end
end
