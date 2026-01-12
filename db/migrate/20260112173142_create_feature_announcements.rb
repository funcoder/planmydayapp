class CreateFeatureAnnouncements < ActiveRecord::Migration[8.0]
  def change
    create_table :feature_announcements do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :version
      t.string :icon, default: 'sparkles'
      t.datetime :published_at
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :feature_announcements, :published_at
    add_index :feature_announcements, :active
  end
end
