class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.datetime :return_date
      t.integer :item_id
      t.integer :buyer_id
      t.boolean :out_scan
      t.boolean :in_scan

      t.timestamps null: false
    end
  end
end
