class HomeController < ApplicationController
  allow_unauthenticated_access
  
  def index
  end
  
  def clear_cookies
  end
  
  def test_banner
  end
  
  def test_notifications
    flash.now[:notice] = params[:notice] if params[:notice]
    flash.now[:alert] = params[:alert] if params[:alert]
  end
end