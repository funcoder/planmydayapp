class Reward < ApplicationRecord
  belongs_to :user

  # Validations
  validates :title, presence: true
  validates :points_required, presence: true, numericality: { greater_than: 0 }
  validates :icon, presence: true
  validates :color, format: { with: /\A#[0-9A-F]{6}\z/i }, allow_blank: true

  # Scopes
  scope :available, -> { where(redeemed: false) }
  scope :redeemed, -> { where(redeemed: true) }
  scope :affordable_for, ->(user) { where('points_required <= ?', user.total_points) }
  scope :by_points, -> { order(points_required: :asc) }

  # Instance methods
  def redeem!
    return false if redeemed?
    return false unless user.total_points >= points_required

    transaction do
      user.add_points(-points_required)
      update!(redeemed: true, redeemed_at: Time.current)
    end
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def affordable_for?(user)
    user.total_points >= points_required
  end

  def points_away_for(user)
    [points_required - user.total_points, 0].max
  end
end