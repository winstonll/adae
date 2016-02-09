class AddLengthToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :length, :string
  end
end
