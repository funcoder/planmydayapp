Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]

  # Only enable Sentry in production
  config.enabled_environments = %w[production]

  # Set traces sample rate for performance monitoring (0.0 to 1.0)
  # Start with a lower rate and increase as needed
  config.traces_sample_rate = 0.1

  # Enable profiling (requires traces_sample_rate > 0)
  config.profiles_sample_rate = 0.1

  # Capture breadcrumbs for better error context
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Filter sensitive parameters
  config.send_default_pii = false

  # Set release version for tracking deployments
  config.release = ENV.fetch("RELEASE_VERSION") { `git rev-parse --short HEAD`.strip rescue "unknown" }

  # Set environment
  config.environment = Rails.env

  # Exclude common bot/scanner errors
  config.excluded_exceptions += [
    "ActionController::RoutingError",
    "ActionController::BadRequest"
  ]
end
