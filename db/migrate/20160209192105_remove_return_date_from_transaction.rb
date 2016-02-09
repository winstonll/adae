class RemoveReturnDateFromTransaction < ActiveRecord::Migration
  def change
      remove_column :transactions, :return_date, :datetime
  end
end
