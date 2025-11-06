class ApplicationController < ActionController::Base
  include Authentication
  # Commenting out allow_browser to prevent 406 errors
  # allow_browser versions: :modern

  # Make helper method available to views
  helper_method :native_app?

  private

  # Detect if the request is from a Hotwire Native app
  def native_app?
    request.user_agent&.match?(/Hotwire Native/)
  end
end
