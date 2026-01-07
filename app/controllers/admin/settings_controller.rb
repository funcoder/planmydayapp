class Admin::SettingsController < ApplicationController
  before_action :require_admin

  def index
    @lifetime_offer_enabled = AppSetting.lifetime_offer_enabled?
  end

  def toggle_lifetime_offer
    if AppSetting.lifetime_offer_enabled?
      AppSetting.disable_lifetime_offer!
      message = "Lifetime offer has been disabled"
    else
      AppSetting.enable_lifetime_offer!
      message = "Lifetime offer has been enabled"
    end

    redirect_to admin_settings_path, notice: message
  end

  private

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "Access denied"
    end
  end
end
