class TasksController < ApplicationController
  include ApiRateLimiter

  VOICE_TASK_DAILY_LIMIT = ENV.fetch("VOICE_TASK_DAILY_LIMIT", 15).to_i
  VOICE_TASK_MAX_DURATION_SECONDS = ENV.fetch("VOICE_TASK_MAX_DURATION_SECONDS", 30).to_i

  before_action :set_task, only: [ :edit, :update, :destroy, :complete, :start, :cancel_start, :rollover, :hold, :resume, :schedule_for_today, :remove_from_today, :move_to_date, :move_to_column ]

  def index
    @filter = params[:filter] || "pending"
    @view = params[:view] || "list"

    if @view == "kanban"
      # For kanban, get all tasks organized by status/schedule
      @pending_tasks = current_user.tasks.where(status: "pending").where("scheduled_for IS NULL OR scheduled_for != ?", Date.current).order(position: :asc, created_at: :desc)
      @today_tasks = current_user.tasks.where(scheduled_for: Date.current).where.not(status: "completed").order(position: :asc, created_at: :desc)
      @completed_tasks = current_user.tasks.where(status: "completed").order(position: :asc, updated_at: :desc).limit(20)
      @tasks = current_user.tasks # For total count
    else
      # List view with filtering
      @tasks = case @filter
      when "today"
                 current_user.tasks.where(scheduled_for: Date.current).order(created_at: :desc)
      when "pending"
                 current_user.tasks.where(status: "pending").order(scheduled_for: :desc, created_at: :desc)
      when "completed"
                 current_user.tasks.where(status: "completed").order(updated_at: :desc)
      else # 'all'
                 current_user.tasks.order(scheduled_for: :desc, created_at: :desc)
      end
    end
  end

  def new
    # If coming from backlog page, don't set scheduled_for
    scheduled_date = params[:scheduled] == "backlog" ? nil : Date.current
    @task = current_user.tasks.build(scheduled_for: scheduled_date, status: "pending")
    if params[:project_id].present?
      @task.project_id = params[:project_id]
      project = current_user.projects.find_by(id: params[:project_id])
      @task.color = project.color if project
    end
    @unscheduled_tasks = current_user.tasks.unscheduled.pending
    @brain_dumps = current_user.brain_dumps.unprocessed.recent.limit(5)
    @projects = current_user.projects.active.ordered if current_user.can_access_notes?
  end

  def create
    @task = current_user.tasks.build(task_params)
    @task.status ||= "pending"
    @task.position ||= current_user.tasks.maximum(:position).to_i + 1

    # Check backlog task limit only if the task is unscheduled (backlog)
    if @task.scheduled_for.nil? && !current_user.can_add_backlog_task?
      redirect_to tasks_path, alert: "You've reached your limit of #{current_user.max_backlog_tasks} backlog tasks on the free plan. Upgrade to Pro for unlimited backlog tasks or schedule a task for today."
      return
    end

    # Check daily task limit only if the task is scheduled for today
    if @task.scheduled_for == Date.current && current_user.tasks.today.incomplete.count >= current_user.daily_task_limit
      redirect_to dashboard_path, alert: "You've reached your daily task limit of #{current_user.daily_task_limit} active tasks. Complete some tasks or move them to another day."
      return
    end

    if @task.save
      # Redirect to backlog if task is unscheduled, otherwise to dashboard
      redirect_path = @task.scheduled_for.nil? ? tasks_path : dashboard_path
      redirect_to redirect_path, notice: "Task added successfully!"
    else
      @unscheduled_tasks = current_user.tasks.unscheduled.pending
      @brain_dumps = current_user.brain_dumps.unprocessed.recent.limit(5)
      @projects = current_user.projects.active.ordered if current_user.can_access_notes?
      render :new
    end
  end

  def transcribe
    unless current_user.can_access_voice_task?
      render json: { error: "Voice to task is available on Pro." }, status: :forbidden
      return
    end

    if params[:audio].blank?
      render json: { error: "Please record some audio first." }, status: :unprocessable_entity
      return
    end

    if ENV["OPENAI_API_KEY"].blank?
      render json: { error: "Voice transcription isn't configured yet." }, status: :service_unavailable
      return
    end

    if params[:duration_seconds].present? && params[:duration_seconds].to_i > VOICE_TASK_MAX_DURATION_SECONDS
      render json: { error: "Recordings must be #{VOICE_TASK_MAX_DURATION_SECONDS} seconds or less." }, status: :unprocessable_entity
      return
    end

    check_api_limit!("voice_task_transcription", custom_limit: VOICE_TASK_DAILY_LIMIT)

    transcript = TaskVoiceTranscriptionService.new(audio_file: params[:audio].tempfile).call
    parsed = TaskVoiceCommandParser.parse(
      transcript,
      default_scheduled_for: params[:default_scheduled_for]
    )

    render json: {
      transcript: transcript,
      task: {
        title: parsed.title,
        description: parsed.description,
        scheduled_for: parsed.scheduled_for,
        time_of_day: parsed.time_of_day
      }
    }, status: :ok
  rescue TaskVoiceTranscriptionService::MissingApiKeyError
    render json: { error: "Voice transcription isn't configured yet." }, status: :service_unavailable
  rescue TaskVoiceTranscriptionService::TranscriptionFailedError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def quick_add
    unless current_user.can_access_voice_task?
      render json: { error: "Voice to task is available on Pro." }, status: :forbidden
      return
    end

    parsed = TaskVoiceCommandParser.parse(params[:transcript].to_s)
    @task = current_user.tasks.build(
      title: parsed.title,
      description: parsed.description,
      priority: "medium",
      status: "pending",
      position: next_task_position
    )

    apply_quick_add_destination!(@task, params[:destination])

    if @task.scheduled_for.nil? && !current_user.can_add_backlog_task?
      render json: { error: "You've reached your backlog limit on the free plan." }, status: :unprocessable_entity
      return
    end

    if @task.scheduled_for == Date.current && current_user.tasks.today.incomplete.count >= current_user.daily_task_limit
      render json: { error: "You've reached your daily task limit for today." }, status: :unprocessable_entity
      return
    end

    if @task.save
      render json: {
        task: {
          id: @task.id,
          title: @task.title,
          scheduled_for: @task.scheduled_for,
          time_of_day: @task.time_of_day
        },
        notice: "Task added successfully!"
      }, status: :created
    else
      render json: { error: @task.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  def edit
    @return_to = safe_return_to
    @projects = current_user.projects.active.ordered if current_user.can_access_notes?
  end

  def update
    if @task.update(task_params)
      redirect_to safe_return_to, notice: "Task updated successfully!"
    else
      @return_to = safe_return_to
      @projects = current_user.projects.active.ordered if current_user.can_access_notes?
      render :edit
    end
  end

  def destroy
    @task.destroy

    respond_to do |format|
      format.html { redirect_back fallback_location: dashboard_path, notice: "Task removed" }
      format.turbo_stream
    end
  end

  def complete
    @task.complete!
    current_user.update_streak

    respond_to do |format|
      format.html { redirect_back fallback_location: dashboard_path, notice: "Great job! Task completed!" }
      format.json { head :ok }
      format.turbo_stream
    end
  end

  def start
    @task.start!

    respond_to do |format|
      format.html { redirect_to dashboard_path, notice: "Task started!" }
      format.json { head :ok }
    end
  end

  def cancel_start
    if @task.in_progress?
      @task.update(status: "pending")
      redirect_to dashboard_path, notice: "Task moved back to pending"
    else
      redirect_to dashboard_path, alert: "Only in-progress tasks can be canceled"
    end
  end

  def hold
    reason = params[:on_hold_reason]
    @task.hold!(reason)
    redirect_to dashboard_path, notice: "Task put on hold"
  end

  def resume
    @task.resume!
    redirect_to dashboard_path, notice: "Task resumed!"
  end

  def rollover
    @task.rollover_to_tomorrow!
    redirect_to dashboard_path, notice: "Task moved to tomorrow"
  end

  def schedule_for_today
    # Check daily task limit
    if current_user.tasks.today.incomplete.count >= current_user.daily_task_limit
      redirect_to tasks_path, alert: "You've reached your daily task limit of #{current_user.daily_task_limit} active tasks."
      return
    end

    time_of_day = params[:time_of_day].presence || @task.time_of_day || "morning"

    unless Task::TIME_OF_DAY_OPTIONS.include?(time_of_day)
      redirect_to tasks_path, alert: "Please choose morning, afternoon, or evening."
      return
    end

    @task.update(scheduled_for: Date.current, time_of_day: time_of_day)
    redirect_to tasks_path, notice: "Task scheduled for today!"
  end

  def remove_from_today
    @task.update(scheduled_for: nil)
    redirect_to dashboard_path, notice: "Task moved to backlog"
  end

  def move_to_date
    new_date = Date.parse(params[:date]) rescue nil

    if new_date.nil?
      redirect_to dashboard_path, alert: "Invalid date selected"
      return
    end

    # Check daily task limit if moving to today
    if new_date == Date.current && current_user.tasks.today.incomplete.count >= current_user.daily_task_limit
      redirect_to dashboard_path, alert: "You've reached your daily task limit for today."
      return
    end

    @task.update(scheduled_for: new_date)
    redirect_to dashboard_path, notice: "Task moved to #{new_date.strftime('%B %d, %Y')}"
  end

  def move_to_column
    column = params[:column]

    case column
    when "pending"
      @task.update(status: "pending", scheduled_for: nil, completed_at: nil)
    when "today"
      if current_user.tasks.today.incomplete.count >= current_user.daily_task_limit
        head :unprocessable_entity
        return
      end
      new_status = @task.completed? ? "pending" : @task.status
      @task.update(status: new_status, scheduled_for: Date.current, completed_at: nil)
    when "completed"
      @task.complete!
      current_user.update_streak
    else
      head :unprocessable_entity
      return
    end

    # Update positions for all tasks in the target column
    if params[:task_ids].present?
      params[:task_ids].each_with_index do |id, index|
        current_user.tasks.where(id: id).update_all(position: index + 1)
      end
    end

    head :ok
  end

  def update_order
    task_ids = params[:task_ids]

    if task_ids.present?
      task_ids.each_with_index do |id, index|
        current_user.tasks.where(id: id).update_all(position: index + 1)
      end
    end

    head :ok
  end

  private

  def set_task
    @task = current_user.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :priority, :estimated_time, :due_date, :scheduled_for, :tag_list, :color, :brain_dump_id, :status, :project_id, :on_hold_reason, :time_of_day)
  end

  def safe_return_to
    url_from(params[:return_to].presence) || url_from(request.referer) || dashboard_path
  end

  def next_task_position
    current_user.tasks.maximum(:position).to_i + 1
  end

  def apply_quick_add_destination!(task, destination)
    case destination
    when "backlog"
      task.scheduled_for = nil
      task.time_of_day = "morning"
    when "morning", "afternoon", "evening"
      task.scheduled_for = Date.current
      task.time_of_day = destination
    else
      raise ActionController::BadRequest, "Invalid destination"
    end
  end
end
