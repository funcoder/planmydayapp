class NotesController < ApplicationController
  before_action :require_notes_access
  before_action :set_note, only: [:show, :edit, :update, :destroy, :pin, :unpin]

  def index
    @filter = params[:filter] || 'all'
    @view = params[:view] || 'list'
    @project_id = params[:project_id]
    @search = params[:search]

    @notes = current_user.notes.includes(:rich_text_content, :project, :task)

    # Apply filters
    @notes = @notes.for_project(@project_id) if @project_id.present?
    @notes = @notes.search(@search) if @search.present?
    @notes = @notes.with_tag(params[:tag]) if params[:tag].present?

    case @filter
    when 'pinned'
      @notes = @notes.pinned
    when 'recent'
      @notes = @notes.recent.limit(20)
    else
      # Show pinned first, then recent
      pinned = @notes.pinned.to_a
      unpinned = @notes.unpinned.recent.to_a
      @notes = pinned + unpinned
    end

    @projects = current_user.projects.active.ordered
  end

  def show
  end

  def new
    @note = current_user.notes.build
    @note.project_id = params[:project_id] if params[:project_id].present?
    @note.task_id = params[:task_id] if params[:task_id].present?
    @projects = current_user.projects.active.ordered
  end

  def create
    @note = current_user.notes.build(note_params)
    @note.position ||= current_user.notes.maximum(:position).to_i + 1

    if @note.save
      redirect_to notes_path, notice: "Note created successfully!"
    else
      @projects = current_user.projects.active.ordered
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @projects = current_user.projects.active.ordered
  end

  def update
    if @note.update(note_params)
      redirect_to notes_path, notice: "Note updated successfully!"
    else
      @projects = current_user.projects.active.ordered
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @note.destroy
    respond_to do |format|
      format.html { redirect_to notes_path, notice: "Note deleted" }
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@note) }
    end
  end

  def pin
    @note.pin!
    respond_to do |format|
      format.html { redirect_to notes_path, notice: "Note pinned" }
      format.turbo_stream
    end
  end

  def unpin
    @note.unpin!
    respond_to do |format|
      format.html { redirect_to notes_path, notice: "Note unpinned" }
      format.turbo_stream
    end
  end

  def update_order
    note_ids = params[:note_ids]

    if note_ids.present?
      note_ids.each_with_index do |id, index|
        note = current_user.notes.find_by(id: id)
        note.update(position: index) if note
      end
    end

    head :ok
  end

  def search_tasks
    query = params[:q].to_s.strip
    @tasks = current_user.tasks.where("title ILIKE ?", "%#{query}%").order(created_at: :desc).limit(10)

    render json: @tasks.map { |t| { id: t.id, title: t.title, status: t.status } }
  end

  private

  def require_notes_access
    unless current_user.can_access_notes?
      redirect_to pricing_path, alert: "Notes are a Pro feature. Upgrade to access!"
    end
  end

  def set_note
    @note = current_user.notes.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:title, :content, :project_id, :task_id, :color, :tag_list, :pinned)
  end
end
