import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "icon", "label"]

  connect() {
    this.storageKey = "planmyday-theme"
    this.mediaQuery = window.matchMedia("(prefers-color-scheme: dark)")
    this.handleSystemThemeChange = this.handleSystemThemeChange.bind(this)
    this.mediaQuery.addEventListener("change", this.handleSystemThemeChange)

    this.apply(this.currentTheme())
  }

  disconnect() {
    this.mediaQuery?.removeEventListener("change", this.handleSystemThemeChange)
  }

  toggle() {
    const nextTheme = this.currentTheme() === "dark" ? "light" : "dark"
    localStorage.setItem(this.storageKey, nextTheme)
    this.apply(nextTheme)
  }

  handleSystemThemeChange() {
    if (localStorage.getItem(this.storageKey)) return

    this.apply(this.systemTheme())
  }

  currentTheme() {
    return document.documentElement.dataset.theme || this.systemTheme()
  }

  systemTheme() {
    return this.mediaQuery.matches ? "dark" : "light"
  }

  apply(theme) {
    const isDark = theme === "dark"
    const nextLabel = isDark ? "Light mode" : "Dark mode"
    const nextIcon = isDark ? "☀️" : "🌙"
    const themeColor = isDark ? "#020617" : "#14b8a6"

    document.documentElement.dataset.theme = theme
    document.documentElement.style.colorScheme = theme
    document.querySelector('meta[name="theme-color"]')?.setAttribute("content", themeColor)

    this.buttonTargets.forEach((button) => {
      button.setAttribute("aria-pressed", String(isDark))
      button.setAttribute("title", nextLabel)
    })

    this.iconTargets.forEach((icon) => {
      icon.textContent = nextIcon
    })

    this.labelTargets.forEach((label) => {
      label.textContent = nextLabel
    })
  }
}
