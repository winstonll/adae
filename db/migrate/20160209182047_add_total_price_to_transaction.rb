class AddTotalPriceToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :total_price, :int
  end
end
