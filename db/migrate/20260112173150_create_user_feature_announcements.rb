class CreateUserFeatureAnnouncements < ActiveRecord::Migration[8.0]
  def change
    create_table :user_feature_announcements do |t|
      t.references :user, null: false, foreign_key: true
      t.references :feature_announcement, null: false, foreign_key: true
      t.datetime :seen_at

      t.timestamps
    end

    add_index :user_feature_announcements, [:user_id, :feature_announcement_id], unique: true, name: 'idx_user_feature_announcements_unique'
  end
end
