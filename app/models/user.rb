class User < ApplicationRecord
  include SubscriptionFeatures

  has_secure_password
  has_many :sessions, dependent: :destroy

  # Associations
  has_many :brain_dumps, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :focus_sessions, dependent: :destroy
  has_many :rewards, dependent: :destroy
  has_many :achievements, dependent: :destroy
  has_many :user_sprites, dependent: :destroy
  has_many :sprite_characters, through: :user_sprites
  has_many :feedbacks, dependent: :destroy
  has_many :cancellation_feedbacks, dependent: :destroy
  has_many :device_tokens, dependent: :destroy
  has_many :user_feature_announcements, dependent: :destroy
  has_many :seen_announcements, through: :user_feature_announcements, source: :feature_announcement

  # Rails 8 features
  # Encrypt sensitive preferences
  encrypts :adhd_profile
  
  # Use Active Storage for profile pictures
  # has_one_attached :avatar # Commented out temporarily

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email_address, presence: true, uniqueness: { case_sensitive: false }

  # Normalizations
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # Scopes
  scope :active_today, -> { where(last_active_date: Date.current) }

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def add_points(points)
    self.total_points += points
    save
  end

  def update_streak
    if last_active_date == Date.yesterday
      self.current_streak += 1
    elsif last_active_date != Date.current
      self.current_streak = 1
    end
    self.last_active_date = Date.current
    save
  end

  def daily_task_limit
    preferences.dig('daily_task_limit') || 5
  end

  def daily_task_limit=(value)
    self.preferences = preferences.merge('daily_task_limit' => value.to_i.clamp(1, 10))
  end

  def preferred_colors
    preferences.dig('colors') || default_colors
  end

  # Feature announcements
  def unseen_announcements
    FeatureAnnouncement.unseen_by(self)
  end

  def unseen_announcements_count
    unseen_announcements.count
  end

  def has_unseen_announcements?
    unseen_announcements.exists?
  end

  def mark_announcements_as_seen(announcements)
    announcements.each { |a| a.mark_as_seen_by(self) }
  end

  private

  def default_colors
    %w[#6366f1 #8b5cf6 #ec4899 #f43f5e #f59e0b #10b981 #06b6d4 #3b82f6]
  end
end