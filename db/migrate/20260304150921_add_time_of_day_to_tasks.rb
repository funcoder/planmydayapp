class AddTimeOfDayToTasks < ActiveRecord::Migration[8.0]
  def change
    add_column :tasks, :time_of_day, :string, default: "morning", null: false
    add_index :tasks, [:user_id, :scheduled_for, :time_of_day]
  end
end
