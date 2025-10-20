class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # Temporarily disabled to debug 406 error
  # allow_browser versions: :modern
end
