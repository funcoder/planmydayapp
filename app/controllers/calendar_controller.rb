class CalendarController < ApplicationController
  def index
    @user = Current.session.user
    
    # Get the week to display (default to current week)
    if params[:week_date].present?
      @current_date = Date.parse(params[:week_date])
    else
      @current_date = Date.current
    end
    
    # Calculate start and end of the week (Monday to Sunday)
    @week_start = @current_date.beginning_of_week(:monday)
    @week_end = @current_date.end_of_week(:monday)
    
    # Get all tasks for this week
    @week_tasks = @user.tasks
                       .where(scheduled_for: @week_start..@week_end)
                       .or(@user.tasks.where(completed_at: @week_start.beginning_of_day..@week_end.end_of_day))
                       .includes(:brain_dump)
    
    # Group tasks by date
    @tasks_by_date = {}
    (@week_start..@week_end).each do |date|
      # Get tasks scheduled for this date or completed on this date
      day_tasks = @week_tasks.select do |task|
        (task.scheduled_for == date) || 
        (task.completed_at && task.completed_at.to_date == date)
      end
      
      @tasks_by_date[date] = {
        scheduled: day_tasks.select { |t| t.scheduled_for == date },
        completed: day_tasks.select { |t| t.completed? && t.completed_at.to_date == date }
      }
    end
    
    # Calculate some stats for the week
    @week_stats = {
      total_scheduled: @week_tasks.where(scheduled_for: @week_start..@week_end).count,
      total_completed: @week_tasks.where(completed_at: @week_start.beginning_of_day..@week_end.end_of_day).count,
      completion_rate: calculate_completion_rate(@week_tasks)
    }
  end
  
  private
  
  def calculate_completion_rate(tasks)
    scheduled = tasks.where(scheduled_for: @week_start..@week_end).count
    return 0 if scheduled.zero?
    
    completed = tasks.where(status: 'completed', scheduled_for: @week_start..@week_end).count
    ((completed.to_f / scheduled) * 100).round
  end
end
