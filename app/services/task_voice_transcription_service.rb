class TaskVoiceTranscriptionService
  class MissingApiKeyError < StandardError; end
  class TranscriptionFailedError < StandardError; end

  MODEL = ENV.fetch("OPENAI_TRANSCRIPTION_MODEL", "gpt-4o-transcribe")
  PROMPT = "This is a short spoken task for a productivity app. Preserve the opening words, use natural punctuation, and do not summarize or rewrite."

  def initialize(audio_file:, language: "en")
    @audio_file = audio_file
    @language = language
  end

  def call
    raise MissingApiKeyError, "OPENAI_API_KEY is not configured" if ENV["OPENAI_API_KEY"].blank?

    response = client.audio.transcribe(
      parameters: {
        model: MODEL,
        file: @audio_file,
        language: @language,
        prompt: PROMPT
      }
    )

    transcript = response["text"].to_s.strip
    raise TranscriptionFailedError, "No transcript was returned" if transcript.blank?

    transcript
  rescue OpenAI::Error => e
    Rails.logger.error("Task voice transcription failed: #{e.class}: #{e.message}")
    raise TranscriptionFailedError, "We couldn't transcribe that recording. Please try again."
  end

  private

  def client
    @client ||= OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
  end
end
