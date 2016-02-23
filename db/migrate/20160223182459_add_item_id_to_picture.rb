class AddItemIdToPicture < ActiveRecord::Migration
  def change
    add_column :pictures, :item_id, :integer
  end
end
