class RemoveStartDateFromTransaction < ActiveRecord::Migration
  def change
      remove_column :transactions, :start_date, :datetime
  end
end
