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

    # Create a focus session
    select @task.title, from: "task_id"
    click_button "Start Focus Mode"

    # Start the timer
    within "#focus_timer" do
      click_button "Start Timer"
      sleep 2 # Let timer run for 2 seconds

      # Check timer is running
      assert_selector "[data-pomodoro-target='pauseButton']", visible: true
      assert_selector "[data-pomodoro-target='startButton']", visible: false
    end

    # Refresh the page
    visit dashboard_path

    # Timer should still be running
    within "#focus_timer" do
      assert_selector "[data-pomodoro-target='pauseButton']", visible: true
      assert_selector "[data-pomodoro-target='startButton']", visible: false

      # Timer should show less than 25:00
      timer_text = find("[data-pomodoro-target='timer']").text
      minutes, seconds = timer_text.split(":").map(&:to_i)
      total_seconds = minutes * 60 + seconds
      assert total_seconds < 1500, "Timer should have counted down"
    end

    # Test pause functionality
    within "#focus_timer" do
      click_button "Pause Timer"
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
      click_button "Resume Timer"
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

      # Verify timer is still counting down
      timer_text = find("[data-pomodoro-target='timer']").text
      minutes, seconds = timer_text.split(":").map(&:to_i)
      total_seconds = minutes * 60 + seconds
      assert total_seconds < 1495, "Timer should continue counting after navigation"
    end
  end

  private

  def login_as(user)
    post session_path, params: { email: user.email, password: "password123456" }
  end
end