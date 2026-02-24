require "test_helper"

class BrainDumpsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in(@user)
  end

  test "should get index" do
    get brain_dumps_url
    assert_response :success
  end
end
