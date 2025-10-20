class PricingController < ApplicationController
  allow_unauthenticated_access

  def index
    @user = current_user
  end
end
