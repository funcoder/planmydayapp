class TaskVoiceCommandParser
  Result = Struct.new(:title, :description, :scheduled_for, :time_of_day, keyword_init: true)

  TODAY_PATTERNS = [
    /\b(?:to|for)\s+today\b/i,
    /\badd\s+.*\bto\s+today\b/i,
    /\btoday\b/i
  ].freeze

  BACKLOG_PATTERNS = [
    /\b(?:to|for)\s+(?:my\s+)?backlog\b/i,
    /\bbacklog\b/i,
    /\blater\b/i
  ].freeze

  LEADING_COMMAND_PATTERN = /\A(?:please\s+)?(?:can you\s+)?(?:add|create|make|capture|remember)\s+/i
  SPLIT_MARKER_PATTERN = /\b(?:description|details|notes?)\b[:,-]?\s*/i

  def self.parse(transcript, default_scheduled_for: nil)
    new(transcript, default_scheduled_for: default_scheduled_for).parse
  end

  def initialize(transcript, default_scheduled_for:)
    @transcript = transcript.to_s.strip
    @default_scheduled_for = normalize_default_date(default_scheduled_for)
  end

  def parse
    text = @transcript.dup
    scheduled_for = extract_schedule(text) || @default_scheduled_for
    time_of_day = extract_time_of_day(text)

    cleaned_text = cleanup(text)
    title, description = extract_title_and_description(cleaned_text)

    Result.new(
      title: title,
      description: description,
      scheduled_for: scheduled_for,
      time_of_day: time_of_day
    )
  end

  private

  def normalize_default_date(value)
    return if value.blank?

    Date.parse(value.to_s)
  rescue ArgumentError
    nil
  end

  def extract_schedule(text)
    return Date.current if TODAY_PATTERNS.any? { |pattern| pattern.match?(text) }
    return nil if BACKLOG_PATTERNS.any? { |pattern| pattern.match?(text) }

    nil
  end

  def extract_time_of_day(text)
    return "evening" if text.match?(/\btonight\b|\bevening\b/i)
    return "afternoon" if text.match?(/\bthis afternoon\b|\bafternoon\b/i)
    return "morning" if text.match?(/\bthis morning\b|\bmorning\b/i)

    nil
  end

  def cleanup(text)
    text
      .gsub(LEADING_COMMAND_PATTERN, "")
      .gsub(/\b(?:to|for)\s+(?:my\s+)?backlog\b/i, "")
      .gsub(/\b(?:to|for)\s+today\b/i, "")
      .gsub(/\b(?:this\s+)?(?:morning|afternoon|evening)\b/i, "")
      .gsub(/\btonight\b/i, "")
      .gsub(/\s+/, " ")
      .gsub(/\A[,\s]+|[,\s]+\z/, "")
      .strip
  end

  def extract_title_and_description(text)
    return [ @transcript, nil ] if text.blank?

    if (match = text.match(SPLIT_MARKER_PATTERN))
      title = text[0...match.begin(0)].strip
      description = text[match.end(0)..].to_s.strip
      return normalize_parts(title, description)
    end

    sentences = text.split(/(?<=[.!?])\s+/).map(&:strip).reject(&:blank?)
    return normalize_parts(sentences.first, sentences.drop(1).join(" ")) if sentences.length > 1

    normalize_parts(text, nil)
  end

  def normalize_parts(title, description)
    normalized_title = title.to_s.gsub(/\A[:\-,.\s]+|[:\-,.\s]+\z/, "").strip
    normalized_description = description.to_s.gsub(/\A[:\-,.\s]+|[:\-,.\s]+\z/, "").strip

    normalized_title = @transcript if normalized_title.blank?
    normalized_description = nil if normalized_description.blank?

    [ normalized_title, normalized_description ]
  end
end
