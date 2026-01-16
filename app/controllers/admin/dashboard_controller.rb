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

    # Feedback
    @feedbacks = Feedback.recent.includes(:user).limit(20)
    @new_feedback_count = Feedback.by_status('new').count
    @in_progress_feedback_count = Feedback.by_status('in_progress').count
  end

  def update_feedback_status
    @feedback = Feedback.find(params[:id])
    if @feedback.update(status: params[:status])
      redirect_to admin_dashboard_path, notice: "Feedback status updated to #{params[:status]}"
    else
      redirect_to admin_dashboard_path, alert: "Failed to update feedback status"
    end
  end

  def destroy_feedback
    @feedback = Feedback.find(params[:id])
    @feedback.destroy
    redirect_to admin_dashboard_path, notice: "Feedback deleted"
  end

  private

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "Access denied"
    end
  end
end
