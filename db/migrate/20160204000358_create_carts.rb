class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|
	  t.belongs_to :user
	  t.references :item
	  t.string :name, null: false
	  t.decimal :price, precision:5, scale: 2, null: false
      t.timestamps null: false
    end
  end
end
