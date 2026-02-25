class Task < ApplicationRecord
  # include ActsAsList - removed as it's not the correct syntax

  belongs_to :user
  belongs_to :brain_dump, optional: true
  belongs_to :project, optional: true
  has_many :focus_sessions, dependent: :destroy

  # ActsAsList configuration
  acts_as_list scope: [:user_id, :scheduled_for]

  # Validations
  validates :title, presence: true
  validates :status, inclusion: { in: %w[pending in_progress completed archived on_hold] }
  validates :priority, inclusion: { in: %w[low medium high urgent] }
  validates :color, format: { with: /\A#[0-9A-F]{6}\z/i }, allow_blank: true

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :in_progress, -> { where(status: 'in_progress') }
  scope :completed, -> { where(status: 'completed') }
  scope :incomplete, -> { where.not(status: %w[completed on_hold]) }
  scope :on_hold, -> { where(status: 'on_hold') }
  scope :scheduled_for_date, ->(date) { where(scheduled_for: date) }
  scope :overdue, -> { where('due_date < ?', Date.current).incomplete }
  scope :by_priority, -> { order(Arel.sql("CASE priority WHEN 'urgent' THEN 0 WHEN 'high' THEN 1 WHEN 'medium' THEN 2 WHEN 'low' THEN 3 END")) }
  scope :today, -> { scheduled_for_date(Date.current) }
  scope :unscheduled, -> { where(scheduled_for: nil) }

  # Callbacks
  before_save :inherit_project_color
  before_save :set_completed_at
  after_update :award_completion_points, if: :completed?
  
  # Rails 8 feature: Broadcast updates
  # Commented out until we create the necessary partials
  # after_create_commit -> { broadcast_prepend_to "tasks", partial: "tasks/task", locals: { task: self } }
  # after_update_commit -> { broadcast_replace_to "tasks", partial: "tasks/task", locals: { task: self } }
  # after_destroy_commit -> { broadcast_remove_to "tasks" }

  # Instance methods
  def complete!
    update(status: 'completed', actual_time: calculate_actual_time, completed_at: Time.current)
  end

  def start!
    update(status: 'in_progress')
  end

  def rollover_to_tomorrow!
    update(scheduled_for: Date.tomorrow)
  end

  def overdue?
    due_date.present? && due_date < Date.current && !completed?
  end

  def completed?
    status == 'completed'
  end

  def pending?
    status == 'pending'
  end

  def in_progress?
    status == 'in_progress'
  end

  def on_hold?
    status == 'on_hold'
  end

  def hold!(reason = nil)
    update(status: 'on_hold', on_hold_reason: reason)
  end

  def resume!
    update(status: 'pending', on_hold_reason: nil, scheduled_for: Date.current)
  end

  def tag_list
    tags.join(', ') if tags.present?
  end

  def tag_list=(tag_string)
    self.tags = tag_string.split(',').map(&:strip).reject(&:blank?)
  end

  def total_focus_time
    focus_sessions.sum(:duration)
  end

  private

  def set_completed_at
    if status_changed? && status == 'completed'
      self.completed_at = Time.current
    elsif status_changed? && status != 'completed'
      self.completed_at = nil
    end
  end

  def award_completion_points
    return unless status_previously_was != 'completed'
    
    points = case priority
             when 'urgent' then 20
             when 'high' then 15
             when 'medium' then 10
             when 'low' then 5
             else 10
             end
    
    user.add_points(points)
  end

  def inherit_project_color
    return unless project_id_changed? && project.present?
    return if color_changed? && !new_record?

    self.color = project.color
  end

  def calculate_actual_time
    (total_focus_time / 60.0).ceil # Convert seconds to minutes, round up
  end
end