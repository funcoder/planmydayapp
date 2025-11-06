class DeviceToken < ApplicationRecord
  belongs_to :user

  # Validations
  validates :token, presence: true, uniqueness: { scope: :user_id }
  validates :platform, presence: true, inclusion: { in: %w[ios android] }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :ios, -> { where(platform: "ios") }
  scope :android, -> { where(platform: "android") }

  # Find or create a device token
  def self.register(user, token, platform)
    find_or_initialize_by(user: user, token: token).tap do |device_token|
      device_token.platform = platform
      device_token.active = true
      device_token.save
    end
  end

  # Deactivate this device token
  def deactivate!
    update(active: false)
  end
end
