require "application_system_test_case"

class FocusTimerPersistenceTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @task = tasks(:one)
    login_as(@user)
  end

  test "timer persists across page refreshes" do
    # Start on dashboard
    visit dashboard_path

    # Create a focus session (starts immediately in running state)
    select @task.title, from: "task_id"
    click_button "Start Focus Mode"

    within "#focus_timer" do
      sleep 2 # Let timer run for 2 seconds

      # Check timer is running
      assert_selector "[data-pomodoro-target='pauseButton']", visible: true
    end

    # Refresh the page
    visit dashboard_path

    # Timer should still be running
    within "#focus_timer" do
      assert_selector "[data-pomodoro-target='pauseButton']", visible: true

      # Timer should show more than 00:00 (counting up)
      timer_text = find("[data-pomodoro-target='timer']").text
      minutes, seconds = timer_text.split(":").map(&:to_i)
      total_seconds = minutes * 60 + seconds
      assert total_seconds > 0, "Timer should have counted up"
    end

    # Test pause functionality
    within "#focus_timer" do
      click_button "Pause"
      sleep 1

      assert_selector "[data-pomodoro-target='resumeButton']", visible: true
      assert_selector "[data-pomodoro-target='pauseButton']", visible: false

      paused_timer = find("[data-pomodoro-target='timer']").text
    end

    # Refresh again
    visit dashboard_path

    # Timer should still be paused
    within "#focus_timer" do
      assert_selector "[data-pomodoro-target='resumeButton']", visible: true
      assert_selector "[data-pomodoro-target='pauseButton']", visible: false

      # Timer should show same time as when paused
      current_timer = find("[data-pomodoro-target='timer']").text
      assert_equal paused_timer, current_timer, "Timer should maintain paused state"
    end

    # Resume timer
    within "#focus_timer" do
      click_button "Resume"
      sleep 2

      assert_selector "[data-pomodoro-target='pauseButton']", visible: true
      assert_selector "[data-pomodoro-target='resumeButton']", visible: false
    end

    # Navigate to another page and back
    visit tasks_path
    visit dashboard_path

    # Timer should still be running
    within "#focus_timer" do
      assert_selector "[data-pomodoro-target='pauseButton']", visible: true

      # Verify timer continues counting up after navigation
      timer_text = find("[data-pomodoro-target='timer']").text
      minutes, seconds = timer_text.split(":").map(&:to_i)
      total_seconds = minutes * 60 + seconds
      assert total_seconds > 5, "Timer should continue counting after navigation"
    end
  end

  private

  def login_as(user)
    post session_path, params: { email: user.email, password: "password123456" }
  end
end
