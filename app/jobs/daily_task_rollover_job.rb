class DailyTaskRolloverJob < ApplicationJob
  queue_as :default

  def perform
    # Find all incomplete tasks from yesterday and move them to today
    yesterday = Date.yesterday
    today = Date.current

    incomplete_tasks = Task.where(scheduled_for: yesterday)
                           .incomplete
                           .includes(:user)

    rolled_over_count = 0

    incomplete_tasks.find_each do |task|
      task.update(scheduled_for: today)
      rolled_over_count += 1
      Rails.logger.info "[DailyTaskRolloverJob] Rolled over task ##{task.id} '#{task.title}' for user ##{task.user_id}"
    end

    Rails.logger.info "[DailyTaskRolloverJob] Completed. Rolled over #{rolled_over_count} tasks."
  end
end
