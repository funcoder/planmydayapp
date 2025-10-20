class ApplicationController < ActionController::Base
  include Authentication
  # Allow browsers - use permissive settings for compatibility
  # Disabled temporarily due to 406 issues
  # allow_browser versions: { safari: "12", chrome: "80", firefox: "78", edge: "80" }
end
