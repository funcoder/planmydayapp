class AddFeatureAnnouncementsForV025 < ActiveRecord::Migration[8.0]
  def up
    FeatureAnnouncement.create!(
      title: "On Hold, Project Time Tracking & More",
      description: <<~HTML,
        <p>A big batch of improvements to help you stay on top of your work:</p>
        <ul>
          <li><strong>On Hold status</strong> &mdash; put tasks on hold with an optional reason so they stay out of your way until you're ready</li>
          <li><strong>Project time tracking</strong> &mdash; see how much time you've spent on each project with a visual chart and monthly summary table</li>
          <li><strong>Count-up focus timer</strong> &mdash; the focus timer now counts up instead of down, so you can work without a fixed deadline</li>
          <li><strong>On hold reason modal</strong> &mdash; add context when you put a task on hold so you remember why later</li>
          <li><strong>Project colours on tasks</strong> &mdash; tasks inherit their project's colour and the dashboard groups tasks by project</li>
          <li><strong>Configurable daily task limit</strong> &mdash; adjust how many tasks you take on each day</li>
        </ul>
      HTML
      version: "0.2.4",
      icon: "rocket",
      published_at: Time.zone.parse("2026-02-24 12:00:00"),
      active: true
    )

    FeatureAnnouncement.create!(
      title: "Kanban Drag & Drop",
      description: <<~HTML,
        <p>You can now drag tasks between columns on the Kanban board:</p>
        <ul>
          <li><strong>Drag between Pending, Today & Completed</strong> &mdash; move tasks between columns with a simple drag and drop</li>
          <li><strong>Drop position preserved</strong> &mdash; cards stay exactly where you drop them in the column</li>
          <li><strong>Visual drop indicator</strong> &mdash; a clear placeholder shows where your task will land</li>
        </ul>
      HTML
      version: "0.2.5",
      icon: "sparkles",
      published_at: Time.zone.parse("2026-02-25 12:00:00"),
      active: true
    )
  end

  def down
    FeatureAnnouncement.where(version: ["0.2.4", "0.2.5"]).destroy_all
  end
end
