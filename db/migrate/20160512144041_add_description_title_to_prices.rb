class AddDescriptionTitleToPrices < ActiveRecord::Migration
  def change
    add_column :prices, :title, :string
    add_column :prices, :description, :string
  end
end
