require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @task = tasks(:one)
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

  test "backlog renders unique mobile and desktop ids for each task row" do
    sign_in(@user)

    get tasks_url(view: "list", filter: "all")

    assert_response :success
    assert_select "#mobile_task_#{@task.id}", count: 1
    assert_select "#desktop_task_#{@task.id}", count: 1
    assert_select "#task_#{@task.id}", count: 0
  end

  test "destroy returns turbo stream removing backlog task from both layouts" do
    sign_in(@user)

    assert_difference("Task.count", -1) do
      delete task_url(@task, format: :turbo_stream)
    end

    assert_response :success
    assert_equal Mime[:turbo_stream].to_s, response.media_type
    assert_includes response.body, %(target="mobile_task_#{@task.id}")
    assert_includes response.body, %(target="desktop_task_#{@task.id}")
  end
end
