import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    const activeTab = this.tabTargets.find((tab) => tab.dataset.active === "true")
    const firstTabWithTasks = this.tabTargets.find((tab) => tab.dataset.hasTasks === "true")
    const defaultPeriod = activeTab?.dataset.period || firstTabWithTasks?.dataset.period || this.tabTargets[0]?.dataset.period

    if (defaultPeriod) {
      this.show(defaultPeriod)
    }
  }

  select(event) {
    this.show(event.currentTarget.dataset.period)
  }

  show(period) {
    this.tabTargets.forEach((tab) => {
      const active = tab.dataset.period === period
      tab.dataset.active = String(active)
      tab.setAttribute("aria-pressed", String(active))
    })

    this.panelTargets.forEach((panel) => {
      panel.classList.toggle("hidden", panel.dataset.period !== period)
    })
  }
}
