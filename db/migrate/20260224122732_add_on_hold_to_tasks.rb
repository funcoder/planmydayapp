class AddOnHoldToTasks < ActiveRecord::Migration[8.0]
  def change
    add_column :tasks, :on_hold_reason, :string
  end
end
