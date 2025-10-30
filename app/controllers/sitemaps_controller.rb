class SitemapsController < ApplicationController
  # Skip authentication for sitemap
  skip_before_action :require_authentication, if: :devise_controller?

  def index
    @urls = [
      {
        loc: root_url,
        lastmod: Date.today,
        changefreq: "daily",
        priority: 1.0
      },
      {
        loc: pricing_url,
        lastmod: Date.today,
        changefreq: "weekly",
        priority: 0.8
      },
      {
        loc: new_registration_url,
        lastmod: Date.today,
        changefreq: "monthly",
        priority: 0.8
      },
      {
        loc: privacy_url,
        lastmod: Date.today,
        changefreq: "monthly",
        priority: 0.5
      },
      {
        loc: terms_url,
        lastmod: Date.today,
        changefreq: "monthly",
        priority: 0.5
      },
      {
        loc: support_url,
        lastmod: Date.today,
        changefreq: "weekly",
        priority: 0.7
      }
    ]

    respond_to do |format|
      format.xml
    end
  end
end
