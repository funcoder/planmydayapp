class ApiUsage < ApplicationRecord
  belongs_to :user
  
  validates :endpoint, presence: true
  validates :count, numericality: { greater_than_or_equal_to: 0 }
  validates :date, presence: true
  validates :user_id, uniqueness: { scope: [:endpoint, :date] }
  
  scope :today, -> { where(date: Date.current) }
  scope :this_week, -> { where(date: 1.week.ago.to_date..Date.current) }
  scope :this_month, -> { where(date: 1.month.ago.to_date..Date.current) }
  
  # Clean up old records (keep last 30 days)
  def self.cleanup_old_records
    where('date < ?', 30.days.ago.to_date).destroy_all
  end
end
