class CreateFocusSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :focus_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :task, null: false, foreign_key: true
      t.datetime :started_at
      t.datetime :ended_at
      t.integer :duration
      t.integer :interruptions
      t.text :notes
      t.integer :focus_quality

      t.timestamps
    end
  end
end