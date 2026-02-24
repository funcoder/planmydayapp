class AddIndexToFocusSessionsStartedAt < ActiveRecord::Migration[8.0]
  def change
    add_index :focus_sessions, :started_at
  end
end
