class CreateCancellationFeedbacks < ActiveRecord::Migration[8.0]
  def change
    create_table :cancellation_feedbacks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :reason
      t.text :details

      t.timestamps
    end
  end
end
