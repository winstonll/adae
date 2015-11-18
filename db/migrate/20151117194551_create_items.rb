class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :title
      t.string :description
      t.string :image
      t.integer :user_id
      t.integer :deposit
      t.boolean :rent2buy
      t.string :tags

      t.timestamps null: false
    end
  end
end
