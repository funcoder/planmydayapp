class ApplicationController < ActionController::Base
  include Authentication
  # Commenting out allow_browser to prevent 406 errors
  # allow_browser versions: :modern

  # Make helper method available to views
  helper_method :native_app?

  # Payment wall - redirect free users to pricing
  before_action :require_payment, unless: :public_page?

  private

  # Detect if the request is from a Hotwire Native app
  def native_app?
    request.user_agent&.match?(/Hotwire Native/)
  end

  def require_payment
    return unless current_user
    return if current_user.admin? # Admins bypass payment
    return if current_user.pro? # Includes lifetime

    # Redirect to pricing page if user is not subscribed
    redirect_to pricing_path, alert: "Please choose a plan to continue using PlanMyDay."
  end

  def public_page?
    # Allow access to these controllers/actions without subscription
    public_controllers = %w[
      home
      sessions
      registrations
      passwords
      pricing
      subscriptions
      webhooks
      hotwire_native
      api/v1/device_tokens
    ]

    public_controllers.include?(controller_name) ||
      controller_path.start_with?('api/') ||
      controller_path.start_with?('admin')
  end
end
