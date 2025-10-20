class DashboardController < ApplicationController
  # Rails 8 built-in authentication - no need for devise authenticate_user!
  
  def index
    @user = Current.session.user
    @today_tasks = @user.tasks.today
    @today_incomplete_tasks = @today_tasks.incomplete.order(
      Arel.sql("CASE status WHEN 'in_progress' THEN 0 WHEN 'pending' THEN 1 END"),
      Arel.sql("CASE priority WHEN 'urgent' THEN 0 WHEN 'high' THEN 1 WHEN 'medium' THEN 2 WHEN 'low' THEN 3 END")
    )
    @today_completed_tasks = @today_tasks.completed
    @brain_dumps = @user.brain_dumps.pending.recent.limit(5)
    @current_focus_session = @user.focus_sessions.in_progress.first
    @recent_achievements = @user.achievements.recent.limit(3)
    @points = @user.total_points
    @streak = @user.current_streak
    
    # Update user streak
    @user.update_streak
    
    # Check and unlock new sprites
    @newly_unlocked_sprites = SpriteCharacter.check_and_unlock_for_user(@user)
    
    # Get today's unlocked sprites
    @todays_sprites = @user.user_sprites.today.includes(:sprite_character)
  end
end