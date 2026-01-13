class PwaController < ApplicationController
  skip_before_action :require_authentication
  skip_forgery_protection only: :service_worker

  def service_worker
    # Service worker must NEVER be cached by the browser
    # This ensures users always get the latest version
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
    response.headers["Service-Worker-Allowed"] = "/"

    render file: Rails.root.join("lib", "service-worker.js"),
           content_type: "application/javascript"
  end
end
