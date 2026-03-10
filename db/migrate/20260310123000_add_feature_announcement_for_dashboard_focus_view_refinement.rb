class AddFeatureAnnouncementForDashboardFocusViewRefinement < ActiveRecord::Migration[8.0]
  def up
    FeatureAnnouncement.create!(
      title: "Calmer Dashboard Focus View & Better Readability",
      description: <<~HTML,
        <p>We've refined the dashboard to make it easier to scan and less overwhelming:</p>
        <ul>
          <li><strong>New Focus View toggle</strong> &mdash; switch to a calmer dashboard mode designed for lower visual noise</li>
          <li><strong>Cleaner hierarchy</strong> &mdash; secondary sections are reduced or collapsed so your active tasks stay central</li>
          <li><strong>Softer colour system</strong> &mdash; focus mode uses a more neutral palette to reduce visual strain</li>
          <li><strong>Improved dark mode contrast</strong> &mdash; morning/afternoon/evening focus panels and tab text are now easier to read</li>
        </ul>
      HTML
      version: "0.2.8",
      icon: "sparkles",
      published_at: Time.zone.parse("2026-03-10 12:30:00"),
      active: true
    )
  end

  def down
    FeatureAnnouncement.where(
      title: "Calmer Dashboard Focus View & Better Readability"
    ).destroy_all
  end
end
