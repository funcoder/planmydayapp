class UserSprite < ApplicationRecord
  belongs_to :user
  belongs_to :sprite_character
  
  validates :user_id, uniqueness: { scope: :sprite_character_id }
  
  scope :recent, -> { order(unlocked_at: :desc) }
  scope :today, -> { where(unlocked_at: Date.current.all_day) }
end
