# TEMPORARY: Force clear stale service worker caches for existing users
# Remove this middleware after 2026-01-19 (one week)
#
# This middleware adds Clear-Site-Data header to all responses to force
# browsers to clear their cache and storage, which includes old service workers.
class ClearSiteDataMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)

    # Add Clear-Site-Data header to force browsers to clear cache and storage
    # This will unregister old service workers and clear their caches
    headers["Clear-Site-Data"] = '"cache", "storage"'

    [status, headers, response]
  end
end
