class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.string :timeframe
      t.decimal :amount
      t.integer :item_id

      t.timestamps null: false
    end
  end
end
