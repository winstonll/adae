class AddPostalCodeToItems < ActiveRecord::Migration
  def change
    add_column :items, :postal_code, :string
  end
end
