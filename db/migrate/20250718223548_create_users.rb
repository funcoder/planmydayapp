class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.string :first_name
      t.string :last_name
      t.jsonb :adhd_profile, default: {}
      t.jsonb :preferences, default: {}
      t.integer :total_points, default: 0
      t.integer :current_streak, default: 0
      t.date :last_active_date

      t.timestamps
    end
    add_index :users, :email_address, unique: true
  end
end