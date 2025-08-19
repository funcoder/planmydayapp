class DashboardController < ApplicationController
  # Rails 8 built-in authentication - no need for devise authenticate_user!
  
  def index
    @user = Current.session.user
    @today_tasks = @user.tasks.today.by_priority
    @today_incomplete_tasks = @today_tasks.incomplete
    @today_completed_tasks = @today_tasks.completed
    @brain_dumps = @user.brain_dumps.pending.recent.limit(5)
    @current_focus_session = @user.focus_sessions.in_progress.first
    @recent_achievements = @user.achievements.recent.limit(3)
    @points = @user.total_points
    @streak = @user.current_streak
    
    # Update user streak
    @user.update_streak
  end
end