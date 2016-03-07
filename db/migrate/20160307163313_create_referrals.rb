class CreateReferrals < ActiveRecord::Migration
  def change
    create_table :referrals do |t|
      t.integer :user_id
      t.string :code
      t.decimal :amount, :default => 0.00, :precision => 10, :scale => 2

      t.timestamps null: false
    end
  end
end
