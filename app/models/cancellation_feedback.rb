class CancellationFeedback < ApplicationRecord
  belongs_to :user

  # Common cancellation reasons
  REASONS = [
    "Too expensive",
    "Not using it enough",
    "Missing features I need",
    "Found a better alternative",
    "Technical issues",
    "Too complicated to use",
    "Other"
  ].freeze

  validates :reason, presence: true
end
