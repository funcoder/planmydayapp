class PricingController < ApplicationController
  allow_unauthenticated_access

  def index
    @user = current_user

    respond_to do |format|
      format.html
    end
  end
end
