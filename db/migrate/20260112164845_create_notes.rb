class CreateNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :notes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :project, foreign_key: true
      t.references :task, foreign_key: true
      t.string :title, null: false
      t.string :color, default: '#6366f1'
      t.string :tags, array: true, default: []
      t.boolean :pinned, default: false
      t.datetime :pinned_at
      t.integer :position

      t.timestamps
    end

    add_index :notes, :pinned
    add_index :notes, [:user_id, :position]
    add_index :notes, [:user_id, :pinned]
    add_index :notes, [:project_id, :position]
    add_index :notes, :tags, using: :gin
  end
end
