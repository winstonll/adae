class AddAddonsToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :addons, :text
  end
end
