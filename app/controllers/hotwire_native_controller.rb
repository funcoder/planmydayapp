class HotwireNativeController < ApplicationController
  # Allow unauthenticated access to path configuration
  allow_unauthenticated_access only: [:path_configuration]

  def path_configuration
    render json: {
      settings: {},
      rules: [
        # Default behavior for all routes
        {
          patterns: [".*"],
          properties: {
            context: "default",
            pull_to_refresh_enabled: true
          }
        },
        # Modal presentation for forms and editing
        {
          patterns: [
            "/tasks/new$", "/tasks/.*/edit$",
            "/brain_dumps/new$",
            "/notes/new$", "/notes/.*/edit$",
            "/projects/new$", "/projects/.*/edit$"
          ],
          properties: {
            context: "modal",
            pull_to_refresh_enabled: false
          }
        },
        # Modal for auth pages
        {
          patterns: ["/signup$", "/session/new$", "/passwords"],
          properties: {
            context: "modal",
            pull_to_refresh_enabled: false
          }
        },
        # Modal for settings and profile
        {
          patterns: ["/profile$"],
          properties: {
            context: "modal",
            pull_to_refresh_enabled: false
          }
        },
        # Modal for pricing and subscription management
        {
          patterns: ["/pricing$", "/subscriptions"],
          properties: {
            context: "modal",
            pull_to_refresh_enabled: false
          }
        }
      ]
    }
  end
end
