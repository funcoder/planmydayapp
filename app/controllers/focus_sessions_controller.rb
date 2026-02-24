class FocusSessionsController < ApplicationController
  before_action :set_focus_session, only: [:show, :update, :end_session, :add_interruption, :pause_timer, :resume_timer]
  
  def create
    # End any existing focus sessions (use end_session! to trigger callbacks)
    current_user.focus_sessions.in_progress.each(&:end_session!)

    @task = current_user.tasks.find(params[:task_id])
    @focus_session = current_user.focus_sessions.build(
      task: @task,
      started_at: Time.current,
      timer_state: 'running'
    )

    if @focus_session.save
      respond_to do |format|
        format.html { redirect_to dashboard_path, notice: "Focus session started for: #{@task.title}" }
        format.json { render json: @focus_session.timer_data }
      end
    else
      respond_to do |format|
        format.html { redirect_to dashboard_path, alert: "Could not start focus session" }
        format.json { render json: { error: @focus_session.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def show
    respond_to do |format|
      format.json { render json: @focus_session.timer_data }
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
    @focus_session.end_session!
    redirect_to dashboard_path, notice: "Focus session ended"
  end
  
  def add_interruption
    @focus_session.add_interruption!
    respond_to do |format|
      format.html { redirect_to dashboard_path, notice: "Interruption recorded" }
      format.json { render json: { interruptions: @focus_session.interruptions } }
    end
  end

  def pause_timer
    @focus_session.pause_timer!
    respond_to do |format|
      format.html { redirect_to dashboard_path }
      format.json { render json: @focus_session.timer_data }
    end
  end

  def resume_timer
    @focus_session.resume_timer!
    respond_to do |format|
      format.html { redirect_to dashboard_path }
      format.json { render json: @focus_session.timer_data }
    end
  end

  private
  
  def set_focus_session
    @focus_session = current_user.focus_sessions.find(params[:id])
  end
  
  def focus_session_params
    params.require(:focus_session).permit(:duration, :interruptions, :notes, :focus_quality)
  end
end