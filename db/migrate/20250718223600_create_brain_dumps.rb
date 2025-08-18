class CreateBrainDumps < ActiveRecord::Migration[8.0]
  def change
    create_table :brain_dumps do |t|
      t.references :user, null: false, foreign_key: true
      t.text :content
      t.boolean :processed, default: false
      t.datetime :processed_at
      t.string :tags, array: true, default: []
      t.string :status, default: 'pending'
      t.string :voice_recording_url

      t.timestamps
    end
    add_index :brain_dumps, :status
    add_index :brain_dumps, :processed
  end
end