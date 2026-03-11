class PricingController < ApplicationController
  allow_unauthenticated_access

  def index
    @user = authenticated? ? current_user : nil
  end
end
