module ApiRateLimiter
  extend ActiveSupport::Concern
  
  class RateLimitExceeded < StandardError; end
  
  # Default limits for different endpoints (calls per day)
  DAILY_LIMITS = {
    'openai' => 50,           # 50 OpenAI calls per day per user
    'brain_dump_ai' => 20,    # 20 AI brain dump processes per day
    'task_suggestions' => 30,  # 30 task suggestion calls per day
    'default' => 100          # Default limit for other endpoints
  }.freeze
  
  # Free tier vs paid tier limits (for future use)
  TIER_MULTIPLIERS = {
    'free' => 1,
    'paid' => 10,
    'premium' => 100
  }.freeze
  
  included do
    rescue_from RateLimitExceeded, with: :handle_rate_limit_exceeded
  end
  
  private
  
  def check_api_limit!(endpoint_name, custom_limit: nil)
    return unless current_user # Skip if no user logged in
    
    daily_limit = custom_limit || DAILY_LIMITS[endpoint_name] || DAILY_LIMITS['default']
    
    # Adjust limit based on user tier (default to free)
    user_tier = current_user.subscription_tier || 'free'
    multiplier = TIER_MULTIPLIERS[user_tier] || 1
    adjusted_limit = daily_limit * multiplier
    
    # Find or create today's usage record
    usage = ApiUsage.find_or_create_by(
      user: current_user,
      endpoint: endpoint_name,
      date: Date.current
    )
    
    # Check if limit exceeded
    if usage.count >= adjusted_limit
      Rails.logger.warn "Rate limit exceeded for user #{current_user.id} on endpoint #{endpoint_name}"
      
      # Send alert email if it's the first time today
      if usage.count == adjusted_limit
        AdminNotificationMailer.rate_limit_alert(current_user, endpoint_name, adjusted_limit).deliver_later
      end
      
      raise RateLimitExceeded, "You've reached your daily limit of #{adjusted_limit} requests for this feature. Please try again tomorrow or upgrade your account."
    end
    
    # Increment the counter
    usage.increment!(:count)
    
    # Return remaining calls
    adjusted_limit - usage.count
  end
  
  def reset_api_limits_for_user(user, endpoint: nil)
    if endpoint
      ApiUsage.where(user: user, endpoint: endpoint, date: Date.current).destroy_all
    else
      ApiUsage.where(user: user, date: Date.current).destroy_all
    end
  end
  
  def get_api_usage_stats(user, days_back: 7)
    ApiUsage.where(user: user, date: days_back.days.ago.to_date..Date.current)
            .group(:endpoint, :date)
            .sum(:count)
  end
  
  def handle_rate_limit_exceeded(exception)
    respond_to do |format|
      format.html do
        redirect_back(
          fallback_location: dashboard_path,
          alert: exception.message
        )
      end
      format.json do
        render json: { error: exception.message }, status: :too_many_requests
      end
      format.turbo_stream do
        flash.now[:alert] = exception.message
        render turbo_stream: turbo_stream.update("flash", partial: "shared/flash")
      end
    end
  end
end