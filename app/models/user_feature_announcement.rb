class UserFeatureAnnouncement < ApplicationRecord
  belongs_to :user
  belongs_to :feature_announcement

  validates :user_id, uniqueness: { scope: :feature_announcement_id }

  scope :recent_first, -> { order(seen_at: :desc) }
end
