class CreateRewards < ActiveRecord::Migration[8.0]
  def change
    create_table :rewards do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.integer :points_required
      t.string :icon
      t.string :color
      t.boolean :redeemed
      t.datetime :redeemed_at

      t.timestamps
    end
  end
end