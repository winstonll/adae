class AddStripeToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :stripe_publishable_key, :string
    add_column :users, :stripe_secret_key, :string
    add_column :users, :stripe_user_id, :string
    add_column :users, :stripe_currency, :string
    add_column :users, :stripe_account_type, :string
    add_column :users, :stripe_account_status, :text
  end
end
