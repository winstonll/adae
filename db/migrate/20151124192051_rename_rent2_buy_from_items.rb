class RenameRent2BuyFromItems < ActiveRecord::Migration
  def change
    rename_column :items, :rent2buy, :type
    change_column :items, :type, :string
  end
end
