class Project < ApplicationRecord
  belongs_to :user
  has_many :notes, dependent: :nullify
  has_many :tasks, dependent: :nullify
  has_many :focus_sessions, through: :tasks

  # ActsAsList for ordering
  acts_as_list scope: :user_id

  # Validations
  validates :name, presence: true
  validates :status, inclusion: { in: %w[active archived completed] }
  validates :color, format: { with: /\A#[0-9A-F]{6}\z/i }, allow_blank: true

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :archived, -> { where(status: 'archived') }
  scope :completed, -> { where(status: 'completed') }
  scope :ordered, -> { order(position: :asc) }

  # Instance methods
  def archive!
    update(status: 'archived', archived_at: Time.current)
  end

  def complete!
    update(status: 'completed')
  end

  def reactivate!
    update(status: 'active', archived_at: nil)
  end

  def notes_count
    notes.count
  end

  def tasks_count
    tasks.count
  end

  def completed_tasks_count
    tasks.completed.count
  end

  def incomplete_tasks_count
    tasks.incomplete.count
  end
end
