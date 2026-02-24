class ProjectsController < ApplicationController
  before_action :require_notes_access
  before_action :set_project, only: [:show, :edit, :update, :destroy, :archive, :complete, :reactivate]

  def index
    @filter = params[:filter] || 'active'
    @projects = case @filter
                when 'archived'
                  current_user.projects.archived.ordered
                when 'completed'
                  current_user.projects.completed.ordered
                else
                  current_user.projects.active.ordered
                end
  end

  def show
    @notes = @project.notes.includes(:rich_text_content).recent
    @tasks = @project.tasks.incomplete.order(created_at: :desc)

    # Time tracking data
    @year = (params[:year] || Date.current.year).to_i
    @month = (params[:month] || Date.current.month).to_i

    # Session-based time tracking aggregation
    year_start = Date.new(@year, 1, 1).beginning_of_day
    year_end = Date.new(@year, 12, 31).end_of_day

    # Actual minutes per month — sum focus session durations grouped by session month
    monthly_actuals = @project.focus_sessions.completed
      .where(started_at: year_start..year_end)
      .group("EXTRACT(MONTH FROM started_at)::integer")
      .sum(:duration)

    # Estimated minutes — attribute each task's estimate to the month of its first session,
    # falling back to completed_at/updated_at for tasks without focus sessions
    first_session_months = @project.focus_sessions.completed
      .where(started_at: year_start..year_end)
      .group(:task_id).minimum(:started_at)

    # Also include tasks with estimates but no focus sessions (completed/on_hold)
    session_task_ids = first_session_months.keys
    no_session_tasks = @project.tasks
      .where.not(estimated_time: [nil, 0])
      .where.not(id: session_task_ids)
      .where(status: %w[completed on_hold in_progress pending])
      .where("completed_at BETWEEN ? AND ? OR updated_at BETWEEN ? AND ?", year_start, year_end, year_start, year_end)

    all_estimated_tasks = @project.tasks.where(id: session_task_ids + no_session_tasks.pluck(:id)).index_by(&:id)
    monthly_estimates = Hash.new(0)
    first_session_months.each do |task_id, first_started|
      monthly_estimates[first_started.month] += all_estimated_tasks[task_id]&.estimated_time.to_i
    end
    no_session_tasks.each do |task|
      ref_date = task.completed_at || task.updated_at
      next unless ref_date && ref_date >= year_start && ref_date <= year_end
      monthly_estimates[ref_date.month] += task.estimated_time.to_i
    end

    # Unique task count per month (sessions + no-session tasks)
    monthly_task_counts = @project.focus_sessions.completed
      .where(started_at: year_start..year_end)
      .group("EXTRACT(MONTH FROM started_at)::integer")
      .distinct.count(:task_id)
    no_session_tasks.each do |task|
      ref_date = task.completed_at || task.updated_at
      next unless ref_date && ref_date >= year_start && ref_date <= year_end
      monthly_task_counts[ref_date.month] = (monthly_task_counts[ref_date.month] || 0) + 1
    end

    @monthly_data = (1..12).map do |m|
      {
        month: m,
        estimated_minutes: monthly_estimates[m] || 0,
        actual_minutes: ((monthly_actuals[m] || 0) / 60.0).ceil,
        task_count: monthly_task_counts[m] || 0
      }
    end

    # Tasks for the selected month: those with sessions OR completed/tracked in this month
    month_start = Date.new(@year, @month, 1).beginning_of_day
    month_end = Date.new(@year, @month, 1).end_of_month.end_of_day
    session_task_ids_for_month = @project.focus_sessions.completed
      .where(started_at: month_start..month_end)
      .distinct.pluck(:task_id)
    no_session_task_ids_for_month = @project.tasks
      .where.not(id: session_task_ids_for_month)
      .where(status: %w[completed on_hold])
      .where("(completed_at BETWEEN ? AND ?) OR (actual_time > 0 AND updated_at BETWEEN ? AND ?)",
             month_start, month_end, month_start, month_end)
      .pluck(:id)
    @monthly_completed_tasks = @project.tasks
      .where(id: session_task_ids_for_month + no_session_task_ids_for_month)
      .order(updated_at: :desc)
  end

  def new
    @project = current_user.projects.build
  end

  def create
    @project = current_user.projects.build(project_params)
    @project.position ||= current_user.projects.maximum(:position).to_i + 1

    if @project.save
      redirect_to projects_path, notice: "Project created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to projects_path, notice: "Project updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: "Project deleted"
  end

  def archive
    @project.archive!
    redirect_to projects_path, notice: "Project archived"
  end

  def complete
    @project.complete!
    redirect_to projects_path, notice: "Project marked as complete!"
  end

  def reactivate
    @project.reactivate!
    redirect_to projects_path, notice: "Project reactivated"
  end

  def update_order
    project_ids = params[:project_ids]

    if project_ids.present?
      project_ids.each_with_index do |id, index|
        project = current_user.projects.find_by(id: id)
        project.update(position: index) if project
      end
    end

    head :ok
  end

  private

  def require_notes_access
    unless current_user.can_access_notes?
      redirect_to pricing_path, alert: "Notes and Projects are a Pro feature. Upgrade to access!"
    end
  end

  def set_project
    @project = current_user.projects.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description, :color, :status)
  end
end
