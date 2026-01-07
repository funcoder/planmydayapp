class Admin::SettingsController < Admin::BaseController
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
end
