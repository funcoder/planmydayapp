class Achievement < ApplicationRecord
  belongs_to :user

  # Validations
  validates :title, presence: true
  validates :badge_icon, presence: true
  validates :badge_color, format: { with: /\A#[0-9A-F]{6}\z/i }, allow_blank: true
  validates :points, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  scope :recent, -> { order(earned_at: :desc) }
  scope :by_points, -> { order(points: :desc) }

  # Callbacks
  after_create :award_points

  # Class methods for achievement types
  def self.award_for_streak!(user, streak_days)
    achievement = case streak_days
                  when 3
                    create_achievement(user, 'Consistent Starter', 'Completed tasks 3 days in a row', '🔥', '#f59e0b', 20)
                  when 7
                    create_achievement(user, 'Week Warrior', 'Completed tasks 7 days in a row', '⚡', '#f59e0b', 50)
                  when 30
                    create_achievement(user, 'Habit Master', 'Completed tasks 30 days in a row', '🏆', '#fbbf24', 200)
                  end
    achievement
  end

  def self.award_for_task_milestone!(user, task_count)
    achievement = case task_count
                  when 10
                    create_achievement(user, 'Task Novice', 'Completed 10 tasks', '✅', '#10b981', 30)
                  when 50
                    create_achievement(user, 'Task Expert', 'Completed 50 tasks', '🎯', '#10b981', 100)
                  when 100
                    create_achievement(user, 'Task Master', 'Completed 100 tasks', '👑', '#10b981', 250)
                  end
    achievement
  end

  def self.award_for_focus_time!(user, total_minutes)
    achievement = case total_minutes
                  when 60
                    create_achievement(user, 'Focus Beginner', '1 hour of focus time', '🧘', '#6366f1', 25)
                  when 300
                    create_achievement(user, 'Focus Pro', '5 hours of focus time', '🧘‍♂️', '#6366f1', 75)
                  when 1440
                    create_achievement(user, 'Focus Zen Master', '24 hours of focus time', '🧘‍♀️', '#6366f1', 300)
                  end
    achievement
  end

  def self.award_for_brain_dumps!(user, dump_count)
    achievement = case dump_count
                  when 5
                    create_achievement(user, 'Mind Clearer', 'Created 5 brain dumps', '🧠', '#ec4899', 15)
                  when 25
                    create_achievement(user, 'Thought Organizer', 'Created 25 brain dumps', '💭', '#ec4899', 60)
                  when 100
                    create_achievement(user, 'Mental Clarity Master', 'Created 100 brain dumps', '🌟', '#ec4899', 150)
                  end
    achievement
  end

  private

  def self.create_achievement(user, title, description, icon, color, points)
    return if user.achievements.exists?(title: title)
    
    user.achievements.create!(
      title: title,
      description: description,
      badge_icon: icon,
      badge_color: color,
      points: points,
      earned_at: Time.current
    )
  end

  def award_points
    user.add_points(points)
  end
end