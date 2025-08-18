class FocusSession < ApplicationRecord
  belongs_to :user
  belongs_to :task

  # Validations
  validates :started_at, presence: true
  validates :focus_quality, inclusion: { in: 1..5 }, allow_nil: true

  # Scopes
  scope :completed, -> { where.not(ended_at: nil) }
  scope :in_progress, -> { where(ended_at: nil) }
  scope :recent, -> { order(started_at: :desc) }
  scope :today, -> { where(started_at: Date.current.beginning_of_day..Date.current.end_of_day) }

  # Callbacks
  before_save :calculate_duration
  after_create :start_task
  after_update :award_focus_points, if: :completed?

  # Instance methods
  def end_session!(quality: nil, notes: nil)
    self.ended_at = Time.current
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

  private

  def calculate_duration
    if ended_at.present? && started_at.present?
      self.duration = (ended_at - started_at).to_i
    end
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
end