class Admin::DashboardController < Admin::BaseController
  def index
    @stats = {
      total_users: User.count,
      free_users: User.where(subscription_tier: "free").count,
      pro_subscribers: User.where(subscription_tier: "pro").count,
      lifetime_subscribers: User.where(subscription_tier: "lifetime").count,
      active_subscriptions: User.where(subscription_status: "active").count,
      cancelling_subscriptions: User.where(subscription_status: "cancelling").count,
      past_due_subscriptions: User.where(subscription_status: "past_due").count,
      new_users_today: User.where("created_at >= ?", Date.current.beginning_of_day).count,
      new_users_this_week: User.where("created_at >= ?", 7.days.ago).count,
      new_users_this_month: User.where("created_at >= ?", 30.days.ago).count
    }

    @recent_users = User.order(created_at: :desc).limit(10)
    @recent_subscribers = User.where(subscription_tier: %w[pro lifetime])
                              .order(updated_at: :desc)
                              .limit(10)
  end
end
