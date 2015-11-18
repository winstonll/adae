class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :score
      t.integer :user_id
      t.integer :item_id

      t.timestamps null: false
    end
  end
end
