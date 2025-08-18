class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.string :status, default: 'pending'
      t.string :priority, default: 'medium'
      t.date :due_date
      t.date :scheduled_for
      t.integer :position
      t.references :brain_dump, foreign_key: true
      t.integer :estimated_time
      t.integer :actual_time
      t.string :tags, array: true, default: []
      t.string :color, default: '#6366f1'
      t.datetime :completed_at

      t.timestamps
    end
    add_index :tasks, :status
    add_index :tasks, :scheduled_for
    add_index :tasks, [:user_id, :position]
  end
end