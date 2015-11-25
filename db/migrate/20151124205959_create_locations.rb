class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :city
      t.string :country
      t.string :postal_code
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
