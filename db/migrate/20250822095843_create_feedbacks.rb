class CreateFeedbacks < ActiveRecord::Migration[8.0]
  def change
    create_table :feedbacks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :feedback_type, null: false
      t.string :subject, null: false
      t.text :message, null: false
      t.string :status, default: 'new', null: false

      t.timestamps
    end
    
    add_index :feedbacks, :feedback_type
    add_index :feedbacks, :status
  end
end
