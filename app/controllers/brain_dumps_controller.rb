class BrainDumpsController < ApplicationController
  before_action :set_brain_dump, only: [:process_dump, :archive]

  def index
    @brain_dumps = current_user.brain_dumps.recent
  end

  def create
    @brain_dump = current_user.brain_dumps.build(brain_dump_params)

    if @brain_dump.save
      respond_to do |format|
        format.html { redirect_to dashboard_path, notice: "Thought captured! Process it later when you're ready." }
        format.json { render json: { success: true, message: "Thought saved!", brain_dump: @brain_dump } }
        format.turbo_stream {
          # Get the 6th brain dump to remove (if it exists) after adding the new one
          brain_dumps_to_keep = current_user.brain_dumps.pending.recent.limit(6).pluck(:id)
          sixth_brain_dump = current_user.brain_dumps.pending.recent.offset(5).limit(1).first

          streams = [
            turbo_stream.prepend("brain_dumps", partial: "brain_dumps/brain_dump", locals: { brain_dump: @brain_dump })
          ]

          # Remove the 6th item if it exists
          if sixth_brain_dump
            streams << turbo_stream.remove(ActionView::RecordIdentifier.dom_id(sixth_brain_dump))
          end

          render turbo_stream: streams
        }
      end
    else
      respond_to do |format|
        format.html { redirect_to dashboard_path, alert: "Couldn't save your thought. Try again?" }
        format.json { render json: { success: false, errors: @brain_dump.errors.full_messages }, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("brain_dump_form", partial: "brain_dumps/form", locals: { brain_dump: @brain_dump }) }
      end
    end
  end

  def process_dump
    task_titles = params[:task_titles].reject(&:blank?)
    task_priorities = params[:task_priorities]
    
    if task_titles.any?
      task_titles.each_with_index do |title, index|
        current_user.tasks.create!(
          title: title,
          priority: task_priorities[index] || 'medium',
          brain_dump_id: @brain_dump.id,
          scheduled_for: Date.current,
          status: 'pending'
        )
      end
      @brain_dump.process!
      redirect_to brain_dumps_path, notice: "Created #{task_titles.count} tasks from your brain dump!"
    else
      redirect_to brain_dumps_path, alert: "Please enter at least one task"
    end
  end

  def archive
    @brain_dump.archive!
    redirect_to dashboard_path, notice: "Brain dump archived"
  end

  private

  def set_brain_dump
    @brain_dump = current_user.brain_dumps.find(params[:id])
  end

  def brain_dump_params
    params.require(:brain_dump).permit(:content, :voice_recording)
  end
end