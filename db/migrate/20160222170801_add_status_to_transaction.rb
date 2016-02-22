class AddStatusToTransaction < ActiveRecord::Migration
  def change
      add_column :transactions, :status, :string, default: "Pending"
  end
end
