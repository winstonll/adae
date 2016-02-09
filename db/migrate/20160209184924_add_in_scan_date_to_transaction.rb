class AddInScanDateToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :in_scan_date, :datetime
  end
end
