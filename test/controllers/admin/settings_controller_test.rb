require "test_helper"

class Admin::SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    sign_in(@admin)
  end

  test "should get index" do
    get admin_settings_url
    assert_response :success
  end
end
