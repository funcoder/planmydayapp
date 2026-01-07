module SubscriptionFeatures
  extend ActiveSupport::Concern

  # Feature limits per subscription tier
  TIER_FEATURES = {
    'free' => {
      max_backlog_tasks: 5,
      has_calendar_access: false,
      has_sprites_access: false,
      price_cents: 0,
      name: 'Free'
    },
    'pro' => {
      max_backlog_tasks: Float::INFINITY,
      has_calendar_access: true,
      has_sprites_access: true,
      price_cents: 500, # $5.00
      name: 'Pro'
    },
    'lifetime' => {
      max_backlog_tasks: Float::INFINITY,
      has_calendar_access: true,
      has_sprites_access: true,
      price_cents: 4999, # $49.99 one-time
      name: 'Lifetime'
    }
  }.freeze

  included do
    # Returns the features hash for the user's subscription tier
    def subscription_features
      TIER_FEATURES[effective_subscription_tier] || TIER_FEATURES['free']
    end

    # Get the effective subscription tier (considers grace period for cancelled subscriptions)
    def effective_subscription_tier
      # If subscription is cancelling but period hasn't ended, keep Pro access
      if subscription_status == 'cancelling' && subscription_period_end && subscription_period_end > Time.current
        'pro'
      else
        subscription_tier || 'free'
      end
    end

    # Check if user has pro or lifetime subscription (including grace period)
    # Admins also get pro-level access
    def pro?
      admin? || ['pro', 'lifetime'].include?(effective_subscription_tier)
    end

    # Check if user has lifetime subscription
    def lifetime?
      effective_subscription_tier == 'lifetime'
    end

    # Check if user is on free tier
    def free_tier?
      effective_subscription_tier == 'free'
    end

    # Check if subscription is cancelled but still in grace period
    def subscription_grace_period?
      subscription_status == 'cancelling' && subscription_period_end && subscription_period_end > Time.current
    end

    # Feature-specific checks
    def can_access_calendar?
      admin? || subscription_features[:has_calendar_access]
    end

    def can_access_sprites?
      admin? || subscription_features[:has_sprites_access]
    end

    def max_backlog_tasks
      admin? ? Float::INFINITY : subscription_features[:max_backlog_tasks]
    end

    def can_add_backlog_task?
      backlog_task_count = tasks.unscheduled.count
      backlog_task_count < max_backlog_tasks
    end
  end

  class_methods do
    def tier_price(tier)
      TIER_FEATURES.dig(tier, :price_cents) || 0
    end

    def tier_name(tier)
      TIER_FEATURES.dig(tier, :name) || 'Free'
    end
  end
end
