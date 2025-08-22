class CreateApiUsages < ActiveRecord::Migration[8.0]
  def change
    create_table :api_usages do |t|
      t.references :user, null: false, foreign_key: true
      t.string :endpoint, null: false
      t.integer :count, default: 0, null: false
      t.date :date, null: false

      t.timestamps
    end
    
    add_index :api_usages, [:user_id, :endpoint, :date], unique: true
    add_index :api_usages, :date
  end
end
