class AddFullNameandPhoneToUsers < ActiveRecord::Migration
  def change

    add_column :users, :name, :string
    add_column :users, :surname, :string
    add_column :users, :phone_number, :string
    add_column :users, :phone_verified, :boolean
  end
end
