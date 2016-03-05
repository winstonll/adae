class ChangeTypeTotalPriceTransactions < ActiveRecord::Migration
  def change
    change_column :transactions, :total_price, :decimal, :default => 0.00, :precision => 10, :scale => 2
  end
end
