class AddSubscriptionPeriodEndToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :subscription_period_end, :datetime
  end
end
