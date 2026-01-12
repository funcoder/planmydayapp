class FeatureAnnouncement < ApplicationRecord
  has_many :user_feature_announcements, dependent: :destroy
  has_many :users_who_saw, through: :user_feature_announcements, source: :user

  validates :title, presence: true
  validates :description, presence: true

  scope :active, -> { where(active: true) }
  scope :published, -> { where.not(published_at: nil).where('published_at <= ?', Time.current) }
  scope :recent_first, -> { order(published_at: :desc) }

  # Get announcements a user hasn't seen yet
  def self.unseen_by(user)
    active.published.recent_first
      .where.not(id: user.user_feature_announcements.select(:feature_announcement_id))
  end

  # Get all announcements for display (seen or not)
  def self.for_user(user)
    active.published.recent_first
  end

  def seen_by?(user)
    user_feature_announcements.exists?(user: user)
  end

  def mark_as_seen_by(user)
    user_feature_announcements.find_or_create_by(user: user) do |ufa|
      ufa.seen_at = Time.current
    end
  end

  # Icon options for the admin to choose from
  ICONS = %w[sparkles rocket star gift bell zap heart flag trophy puzzle].freeze
end
