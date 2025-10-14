class AddTimerStateToFocusSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :focus_sessions, :paused_at, :datetime
    add_column :focus_sessions, :timer_duration, :integer, default: 1500 # 25 minutes in seconds
    add_column :focus_sessions, :timer_state, :string, default: 'stopped'
    add_column :focus_sessions, :timer_remaining, :integer # seconds remaining when paused
    add_column :focus_sessions, :total_paused_duration, :integer, default: 0 # total pause time in seconds
  end
end
