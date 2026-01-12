class Note < ApplicationRecord
  belongs_to :user
  belongs_to :project, optional: true
  belongs_to :task, optional: true

  # Rails 8 feature: Rich text for content
  has_rich_text :content

  # ActsAsList for ordering within user
  acts_as_list scope: :user_id

  # Validations
  validates :title, presence: true
  validates :color, format: { with: /\A#[0-9A-F]{6}\z/i }, allow_blank: true

  # Scopes
  scope :pinned, -> { where(pinned: true).order(pinned_at: :desc) }
  scope :unpinned, -> { where(pinned: false) }
  scope :recent, -> { order(updated_at: :desc) }
  scope :ordered, -> { order(position: :asc) }
  scope :for_project, ->(project_id) { where(project_id: project_id) }
  scope :without_project, -> { where(project_id: nil) }
  scope :with_tag, ->(tag) { where("? = ANY(tags)", tag) }
  scope :search, ->(query) {
    left_joins(:rich_text_content)
      .where("notes.title ILIKE :q OR action_text_rich_texts.body ILIKE :q", q: "%#{query}%")
  }

  # Callbacks
  after_create :award_note_points

  # Instance methods
  def pin!
    update(pinned: true, pinned_at: Time.current)
  end

  def unpin!
    update(pinned: false, pinned_at: nil)
  end

  def tag_list
    tags.join(', ') if tags.present?
  end

  def tag_list=(tag_string)
    self.tags = tag_string.to_s.split(',').map(&:strip).reject(&:blank?)
  end

  def content_preview(length = 150)
    content.to_plain_text.truncate(length) if content.present?
  end

  private

  def award_note_points
    user.add_points(3)
  end
end
