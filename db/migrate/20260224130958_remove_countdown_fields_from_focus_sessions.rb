class RemoveCountdownFieldsFromFocusSessions < ActiveRecord::Migration[8.0]
  def change
    remove_column :focus_sessions, :timer_duration, :integer, default: 1500
    remove_column :focus_sessions, :timer_remaining, :integer
  end
end
