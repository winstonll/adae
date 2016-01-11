class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.string :title
      t.string :description
      t.integer :user_id
      t.string :tags
      t.string :timeframe
      t.string :postal_code
    end
  end
end