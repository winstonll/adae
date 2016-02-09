class AddOutScanToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :out_scan_date, :datetime
  end
end
