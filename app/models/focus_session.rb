class FocusSession < ApplicationRecord
  belongs_to :user
  belongs_to :task

  # Validations
  validates :started_at, presence: true
  validates :focus_quality, inclusion: { in: 1..5 }, allow_nil: true
  validates :timer_state, inclusion: { in: %w[stopped running paused] }

  # Scopes
  scope :completed, -> { where.not(ended_at: nil) }
  scope :in_progress, -> { where(ended_at: nil) }
  scope :recent, -> { order(started_at: :desc) }
  scope :today, -> { where(started_at: Date.current.beginning_of_day..Date.current.end_of_day) }
  scope :running, -> { where(timer_state: 'running') }

  # Callbacks
  before_save :calculate_duration
  after_create :start_task
  after_update :award_focus_points, if: :completed?
  after_update :update_task_actual_time, if: :completed?
  after_update_commit :broadcast_timer_update

  # Instance methods
  def end_session!(quality: nil, notes: nil)
    # If paused, account for the current pause before ending
    if timer_state == 'paused' && paused_at.present?
      self.total_paused_duration += (Time.current - paused_at).to_i
    end

    self.ended_at = Time.current
    self.timer_state = 'stopped'
    self.paused_at = nil
    self.focus_quality = quality if quality.present?
    self.notes = notes if notes.present?
    save
  end

  def completed?
    ended_at.present?
  end

  def in_progress?
    ended_at.nil?
  end

  def duration_in_minutes
    return 0 unless duration
    duration / 60
  end

  def add_interruption!
    self.interruptions ||= 0
    self.interruptions += 1
    save
  end

  def quality_emoji
    case focus_quality
    when 5 then '🌟'
    when 4 then '😊'
    when 3 then '😐'
    when 2 then '😕'
    when 1 then '😞'
    else '❓'
    end
  end

  # Timer state management
  def pause_timer!
    return unless timer_state == 'running'
    self.timer_state = 'paused'
    self.paused_at = Time.current
    save
  end

  def resume_timer!
    return unless timer_state == 'paused'

    # Calculate how long we were paused
    pause_duration = Time.current - paused_at
    self.total_paused_duration += pause_duration.to_i

    self.timer_state = 'running'
    self.paused_at = nil
    save
  end

  def calculate_elapsed_seconds
    return 0 unless started_at

    reference_time = case timer_state
                     when 'paused' then paused_at || Time.current
                     when 'stopped' then ended_at || started_at
                     else Time.current
                     end

    [(reference_time - started_at).to_i - (total_paused_duration || 0), 0].max
  end

  def timer_data
    {
      id: id,
      state: timer_state,
      elapsed: calculate_elapsed_seconds,
      started_at: started_at&.iso8601,
      paused_at: paused_at&.iso8601,
      total_paused_duration: total_paused_duration,
      task_title: task.title
    }
  end

  private

  def calculate_duration
    if ended_at.present? && started_at.present?
      self.duration = [(ended_at - started_at).to_i - (total_paused_duration || 0), 0].max
    end
  end

  def update_task_actual_time
    return unless ended_at_previously_was.nil?

    task.update_column(:actual_time, task.total_focus_time / 60)
  end

  def start_task
    task.start! if task.status == 'pending'
  end

  def award_focus_points
    return unless ended_at_previously_was.nil?

    base_points = case duration_in_minutes
                  when 0..14 then 5
                  when 15..29 then 10
                  when 30..59 then 20
                  else 30
                  end

    # Bonus for high quality focus
    base_points += 5 if focus_quality && focus_quality >= 4

    # Penalty for many interruptions
    base_points -= (interruptions || 0) * 2

    user.add_points([base_points, 0].max) # Ensure points are never negative
  end

  def broadcast_timer_update
    # Temporarily disabled to debug layout issues
    # broadcast_replace_to "user_#{user_id}_timer",
    #                     target: "focus_timer",
    #                     partial: "dashboard/focus_timer",
    #                     locals: { focus_session: self }
  end
end