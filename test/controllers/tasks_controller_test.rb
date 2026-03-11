require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should get new for admin user" do
    sign_in(@user)
    get new_task_url
    assert_response :success
  end

  test "should get new for free user" do
    sign_in(users(:two))

    get new_task_url

    assert_response :success
  end
end
