class RemoveOutScanFromTransaction < ActiveRecord::Migration
  def change
      remove_column :transactions, :out_scan, :boolean
  end
end
