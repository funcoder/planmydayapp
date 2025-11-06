class AppSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :value_type, inclusion: { in: %w[string boolean integer] }

  # Get a setting value
  def self.get(key, default = nil)
    setting = find_by(key: key.to_s)
    return default unless setting

    case setting.value_type
    when 'boolean'
      ActiveModel::Type::Boolean.new.cast(setting.value)
    when 'integer'
      setting.value.to_i
    else
      setting.value
    end
  end

  # Set a setting value
  def self.set(key, value, value_type = 'string')
    setting = find_or_initialize_by(key: key.to_s)
    setting.value = value.to_s
    setting.value_type = value_type
    setting.save!
  end

  # Specific settings
  def self.lifetime_offer_enabled?
    get('lifetime_offer_enabled', true) # Default to true (enabled)
  end

  def self.enable_lifetime_offer!
    set('lifetime_offer_enabled', 'true', 'boolean')
  end

  def self.disable_lifetime_offer!
    set('lifetime_offer_enabled', 'false', 'boolean')
  end
end
