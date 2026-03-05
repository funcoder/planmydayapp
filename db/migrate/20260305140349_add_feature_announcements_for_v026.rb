class AddFeatureAnnouncementsForV026 < ActiveRecord::Migration[8.0]
  def up
    FeatureAnnouncement.create!(
      title: "Full-Width Layout & Table Backlog",
      description: <<~HTML,
        <p>We've made some nice improvements to help you use more of your screen:</p>
        <ul>
          <li><strong>Full-width layout</strong> &mdash; the dashboard, calendar, backlog, and all main pages now stretch to use your full screen width</li>
          <li><strong>Table view for Backlog</strong> &mdash; the list view is now a proper table with columns for status, priority, project, scheduled date, due date, time estimates, and more</li>
          <li><strong>Improved task cards</strong> &mdash; tasks on the dashboard now have shadows and a subtle lift effect on hover so they stand out better</li>
          <li><strong>Morning / Afternoon / Evening scheduling</strong> &mdash; assign tasks to a time of day so you can plan your focus across the day</li>
        </ul>
      HTML
      version: "0.2.6",
      icon: "sparkles",
      published_at: Time.zone.parse("2026-03-05 12:00:00"),
      active: true
    )
  end

  def down
    FeatureAnnouncement.where(version: "0.2.6").destroy_all
  end
end
