class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :password_digest
      t.string :address_line1
      t.string :city
      t.string :image
      t.string :phone_number
      t.string :postal_code
      t.boolean :phone_verified

      t.timestamps null: false
    end
  end
end
