require "test_helper"

class BrainDumpsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get brain_dumps_create_url
    assert_response :success
  end
end
