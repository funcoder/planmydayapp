require "test_helper"

class SpritesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get sprites_index_url
    assert_response :success
  end
end
