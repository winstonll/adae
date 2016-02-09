class RemoveEndDateFromTransaction < ActiveRecord::Migration
  def change
      remove_column :transactions, :end_date, :datetime
  end
end
