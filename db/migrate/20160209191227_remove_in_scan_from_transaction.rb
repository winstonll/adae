class RemoveInScanFromTransaction < ActiveRecord::Migration
  def change
      remove_column :transactions, :in_scan, :boolean
  end
end
