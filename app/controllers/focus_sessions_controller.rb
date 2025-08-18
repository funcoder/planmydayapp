class FocusSessionsController < ApplicationController
  before_action :set_focus_session, only: [:update, :end_session, :add_interruption]
  
  def create
    # End any existing focus session
    current_user.focus_sessions.in_progress.update_all(ended_at: Time.current)
    
    @task = current_user.tasks.find(params[:task_id])
    @focus_session = current_user.focus_sessions.build(
      task: @task,
      started_at: Time.current
    )
    
    if @focus_session.save
      redirect_to dashboard_path, notice: "Focus session started for: #{@task.title}"
    else
      redirect_to dashboard_path, alert: "Could not start focus session"
    end
  end
  
  def update
    if @focus_session.update(focus_session_params)
      redirect_to dashboard_path
    else
      redirect_to dashboard_path, alert: "Could not update focus session"
    end
  end
  
  def end_session
    @focus_session.update(ended_at: Time.current)
    redirect_to dashboard_path, notice: "Focus session ended"
  end
  
  def add_interruption
    @focus_session.increment!(:interruptions)
    redirect_to dashboard_path, notice: "Interruption recorded"
  end
  
  private
  
  def set_focus_session
    @focus_session = current_user.focus_sessions.find(params[:id])
  end
  
  def focus_session_params
    params.require(:focus_session).permit(:duration, :interruptions, :notes, :focus_quality)
  end
end