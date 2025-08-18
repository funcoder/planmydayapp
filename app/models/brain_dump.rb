class BrainDump < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :nullify
  
  # Rails 8 feature: Rich text for content
  # has_rich_text :rich_content # Commented out temporarily

  # Validations
  validates :content, presence: true
  validates :status, inclusion: { in: %w[pending processing processed archived] }

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :processed, -> { where(processed: true) }
  scope :unprocessed, -> { where(processed: false) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  after_create :award_brain_dump_points

  # Instance methods
  def process!
    return if processed?

    self.processed = true
    self.processed_at = Time.current
    self.status = 'processed'
    save
  end

  def archive!
    update(status: 'archived')
  end

  def add_tags(new_tags)
    self.tags = (tags + new_tags).uniq
    save
  end

  def tag_list
    tags.join(', ') if tags.present?
  end

  def tag_list=(tag_string)
    self.tags = tag_string.split(',').map(&:strip).reject(&:blank?)
  end

  private

  def award_brain_dump_points
    user.add_points(5) # Award 5 points for each brain dump
  end
end