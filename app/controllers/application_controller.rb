class ApplicationController < ActionController::Base
  include Authentication
  # Commenting out allow_browser to prevent 406 errors
  # allow_browser versions: :modern
end
