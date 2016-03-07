class CreateReferreds < ActiveRecord::Migration
  def change
    create_table :referreds do |t|
      t.integer :provider
      t.integer :redeemer

      t.timestamps null: false
    end
  end
end
