class AddFeatureAnnouncementForDarkModeAndFreeTier < ActiveRecord::Migration[8.0]
  def up
    FeatureAnnouncement.create!(
      title: "Dark Mode, Better Today Flow & Free Tier Access",
      description: <<~HTML,
        <p>We've shipped a few helpful improvements across the app:</p>
        <ul>
          <li><strong>Dark mode</strong> &mdash; switch between light and dark themes from the theme toggle in the header</li>
          <li><strong>Better Today Flow</strong> &mdash; the dashboard focus area now uses a cleaner time-of-day planner instead of cramped Kanban columns</li>
          <li><strong>Free tier access</strong> &mdash; free accounts can now use the app without being forced to choose a paid plan first</li>
          <li><strong>Updated pricing page</strong> &mdash; pricing now shows the Free plan clearly, including your current plan status when you're logged in</li>
        </ul>
      HTML
      version: "0.2.7",
      icon: "star",
      published_at: Time.zone.parse("2026-03-08 20:30:00"),
      active: true
    )
  end

  def down
    FeatureAnnouncement.where(
      title: "Dark Mode, Better Today Flow & Free Tier Access"
    ).destroy_all
  end
end
