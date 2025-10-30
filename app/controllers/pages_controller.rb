class PagesController < ApplicationController
  # Skip authentication for public pages
  skip_before_action :require_authentication, only: [:privacy, :terms, :support]

  def privacy
  end

  def terms
  end

  def support
  end
end
