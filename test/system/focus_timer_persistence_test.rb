require "application_system_test_case"

class FocusTimerPersistenceTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @task = tasks(:one)
    @task.update!(scheduled_for: Date.current, status: "pending")
    @focus_session = @user.focus_sessions.create!(
      task: @task,
      started_at: 2.seconds.ago,
      timer_state: "running"
    )
    login_as(@user)
  end

  test "timer persists across page refreshes" do
    visit dashboard_path

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
      @refreshed_total_seconds = minutes * 60 + seconds
      assert @refreshed_total_seconds > 0, "Timer should have counted up"
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
      assert total_seconds >= @refreshed_total_seconds, "Timer should continue counting after navigation"
    end
  end

  private

  def login_as(user)
    visit new_session_path
    fill_in "Email address", with: user.email_address
    fill_in "Password", with: "password"
    click_button "Sign In"
  end
end
