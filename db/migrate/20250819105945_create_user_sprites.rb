class CreateUserSprites < ActiveRecord::Migration[8.0]
  def change
    create_table :user_sprites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :sprite_character, null: false, foreign_key: true
      t.datetime :unlocked_at

      t.timestamps
    end
  end
end
