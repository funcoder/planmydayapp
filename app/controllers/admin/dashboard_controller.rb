class Admin::DashboardController < ApplicationController
  before_action :require_admin

  def index
    @total_users = User.count
    @free_users = User.where(subscription_tier: [nil, 'free']).count
    @pro_users = User.where(subscription_tier: 'pro').count
    @lifetime_users = User.where(subscription_tier: 'lifetime').count
    @active_subscriptions = User.where(subscription_status: 'active').count
    @cancelling_subscriptions = User.where(subscription_status: 'cancelling').count

    # Recent signups
    @users_today = User.where('created_at >= ?', Time.current.beginning_of_day).count
    @users_this_week = User.where('created_at >= ?', 1.week.ago).count
    @users_this_month = User.where('created_at >= ?', 1.month.ago).count

    # Revenue estimates
    @monthly_recurring_revenue = @pro_users * 5.00
    @lifetime_revenue = @lifetime_users * 49.99
  end

  private

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "Access denied"
    end
  end
end
