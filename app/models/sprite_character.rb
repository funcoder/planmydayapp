class SpriteCharacter < ApplicationRecord
  has_many :user_sprites, dependent: :destroy
  has_many :users, through: :user_sprites
  
  validates :name, presence: true, uniqueness: true
  validates :unlock_condition, presence: true
  validates :sprite_type, inclusion: { in: %w[points streak tasks special daily achievement] }
  validates :rarity, inclusion: { in: %w[common uncommon rare epic legendary] }
  
  scope :by_rarity, -> { order(Arel.sql("CASE rarity WHEN 'legendary' THEN 0 WHEN 'epic' THEN 1 WHEN 'rare' THEN 2 WHEN 'uncommon' THEN 3 WHEN 'common' THEN 4 END")) }
  scope :common, -> { where(rarity: 'common') }
  scope :uncommon, -> { where(rarity: 'uncommon') }
  scope :rare, -> { where(rarity: 'rare') }
  scope :epic, -> { where(rarity: 'epic') }
  scope :legendary, -> { where(rarity: 'legendary') }
  
  def self.check_and_unlock_for_user(user)
    unlocked_today = []
    
    all.each do |sprite|
      next if user.sprite_characters.include?(sprite)
      
      if sprite.unlock_condition_met?(user)
        user.user_sprites.create!(sprite_character: sprite, unlocked_at: Time.current)
        unlocked_today << sprite
      end
    end
    
    unlocked_today
  end
  
  def unlock_condition_met?(user)
    case sprite_type
    when 'points'
      user.total_points >= unlock_value
    when 'streak'
      user.current_streak >= unlock_value
    when 'tasks'
      user.tasks.completed.count >= unlock_value
    when 'daily'
      user.tasks.completed.where(completed_at: Date.current.all_day).count >= unlock_value
    when 'achievement'
      user.achievements.count >= unlock_value
    when 'special'
      check_special_condition(user)
    else
      false
    end
  end
  
  private
  
  def check_special_condition(user)
    case unlock_condition
    when 'perfect_week'
      # Completed at least 5 tasks every day for 7 days
      (0..6).all? do |days_ago|
        date = Date.current - days_ago.days
        user.tasks.completed.where(completed_at: date.all_day).count >= 5
      end
    when 'early_bird'
      # Completed a task before 8 AM
      user.tasks.completed.any? { |t| t.completed_at && t.completed_at.hour < 8 }
    when 'night_owl'
      # Completed a task after 10 PM
      user.tasks.completed.any? { |t| t.completed_at && t.completed_at.hour >= 22 }
    when 'weekend_warrior'
      # Completed tasks on both Saturday and Sunday this week
      saturday = Date.current.beginning_of_week(:monday) + 5.days
      sunday = saturday + 1.day
      user.tasks.completed.where(completed_at: saturday.all_day).exists? &&
        user.tasks.completed.where(completed_at: sunday.all_day).exists?
    else
      false
    end
  end
end
