class CreateAchievements < ActiveRecord::Migration[8.0]
  def change
    create_table :achievements do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.string :badge_icon
      t.string :badge_color
      t.datetime :earned_at
      t.integer :points

      t.timestamps
    end
  end
end