class AddStripeFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :stripe_customer_id, :string
    add_column :users, :stripe_subscription_id, :string
    add_column :users, :subscription_status, :string, default: 'inactive'

    add_index :users, :stripe_customer_id, unique: true
    add_index :users, :stripe_subscription_id
    add_index :users, :subscription_status
  end
end
