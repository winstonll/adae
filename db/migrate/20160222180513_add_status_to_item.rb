class AddStatusToItem < ActiveRecord::Migration
  def change
      add_column :items, :status, :string, default: "Listed"
  end
end
