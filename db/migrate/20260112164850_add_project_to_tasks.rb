class AddProjectToTasks < ActiveRecord::Migration[8.0]
  def change
    add_reference :tasks, :project, foreign_key: true
    add_index :tasks, [:project_id, :status]
  end
end
