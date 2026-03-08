require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should get index for admin user" do
    sign_in(@user)
    get dashboard_url
    assert_response :success
  end

  test "should get index for free user" do
    sign_in(users(:two))

    get dashboard_url

    assert_response :success
  end
end
