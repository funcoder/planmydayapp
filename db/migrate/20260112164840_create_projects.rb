class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :color, default: '#6366f1'
      t.string :status, default: 'active'
      t.integer :position
      t.datetime :archived_at

      t.timestamps
    end

    add_index :projects, :status
    add_index :projects, [:user_id, :position]
    add_index :projects, [:user_id, :status]
  end
end
