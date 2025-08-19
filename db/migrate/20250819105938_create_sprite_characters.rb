class CreateSpriteCharacters < ActiveRecord::Migration[8.0]
  def change
    create_table :sprite_characters do |t|
      t.string :name
      t.text :description
      t.string :unlock_condition
      t.integer :unlock_value
      t.string :sprite_type
      t.string :css_class
      t.string :rarity

      t.timestamps
    end
  end
end
