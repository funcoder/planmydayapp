require "test_helper"

class SpritesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in(@user)
  end

  test "should get index" do
    get sprites_url
    assert_response :success
  end
end
