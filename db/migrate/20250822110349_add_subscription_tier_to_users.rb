class AddSubscriptionTierToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :subscription_tier, :string, default: 'free', null: false
    add_index :users, :subscription_tier
  end
end
