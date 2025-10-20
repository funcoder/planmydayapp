class TasksController < ApplicationController
  before_action :set_task, only: [:edit, :update, :destroy, :complete, :start, :rollover, :schedule_for_today]

  def index
    @tasks = current_user.tasks.order(scheduled_for: :desc, created_at: :desc)
  end

  def new
    # If coming from backlog page, don't set scheduled_for
    scheduled_date = params[:scheduled] == 'backlog' ? nil : Date.current
    @task = current_user.tasks.build(scheduled_for: scheduled_date, status: 'pending')
    @unscheduled_tasks = current_user.tasks.unscheduled.pending
    @brain_dumps = current_user.brain_dumps.unprocessed.recent.limit(5)
  end

  def create
    @task = current_user.tasks.build(task_params)
    @task.status ||= 'pending'
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
      render :new
    end
  end

  def edit
  end

  def update
    if @task.update(task_params)
      redirect_to dashboard_path, notice: "Task updated successfully!"
    else
      render :edit
    end
  end

  def destroy
    @task.destroy
    redirect_to dashboard_path, notice: "Task removed"
  end

  def complete
    @task.complete!
    current_user.update_streak
    
    respond_to do |format|
      format.html { redirect_to dashboard_path, notice: "Great job! Task completed! 🎉" }
      format.turbo_stream
    end
  end

  def start
    @task.start!
    redirect_to dashboard_path, notice: "Task started!"
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

    @task.update(scheduled_for: Date.current)
    redirect_to tasks_path, notice: "Task scheduled for today!"
  end

  def update_order
    task_ids = params[:task_ids]
    
    if task_ids.present?
      task_ids.each_with_index do |id, index|
        task = current_user.tasks.find_by(id: id)
        task.update(position: index) if task
      end
    end
    
    head :ok
  end

  private

  def set_task
    @task = current_user.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :priority, :estimated_time, :due_date, :scheduled_for, :tag_list, :color, :brain_dump_id, :status)
  end
end