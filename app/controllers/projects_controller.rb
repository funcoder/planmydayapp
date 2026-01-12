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
