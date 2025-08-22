class Feedback < ApplicationRecord
  belongs_to :user
  
  FEEDBACK_TYPES = ['bug_report', 'feature_request', 'general_feedback', 'other'].freeze
  
  validates :feedback_type, presence: true, inclusion: { in: FEEDBACK_TYPES }
  validates :subject, presence: true, length: { maximum: 200 }
  validates :message, presence: true, length: { maximum: 5000 }
  validates :status, presence: true, inclusion: { in: ['new', 'in_progress', 'resolved', 'closed'] }
  
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(feedback_type: type) }
  scope :by_status, ->(status) { where(status: status) }
end
