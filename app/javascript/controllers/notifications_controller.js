import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["status"]

  connect() {
    this.checkNotificationPermission()
  }

  checkNotificationPermission() {
    if (!("Notification" in window)) {
      console.log("This browser does not support notifications")
      return
    }

    if (Notification.permission === "granted") {
      this.updateStatus("Notifications enabled")
    } else if (Notification.permission === "denied") {
      this.updateStatus("Notifications blocked")
    }
  }

  async requestPermission() {
    if (!("Notification" in window)) {
      alert("This browser does not support desktop notifications")
      return
    }

    if (Notification.permission === "granted") {
      this.showTestNotification()
      return
    }

    if (Notification.permission !== "denied") {
      const permission = await Notification.requestPermission()

      if (permission === "granted") {
        this.updateStatus("Notifications enabled")
        this.showTestNotification()
      } else {
        this.updateStatus("Notifications blocked")
      }
    } else {
      alert("Notifications are blocked. Please enable them in your browser settings.")
    }
  }

  showTestNotification() {
    if (Notification.permission === "granted") {
      const notification = new Notification("PlanMyDay", {
        body: "Notifications are now enabled! You'll receive reminders for your tasks.",
        icon: "/icon-192.png",
        badge: "/icon-192.png",
        vibrate: [200, 100, 200],
        tag: "test-notification"
      })

      notification.onclick = () => {
        window.focus()
        notification.close()
      }
    }
  }

  scheduleTaskReminder(taskTitle, minutes) {
    if (Notification.permission !== "granted") {
      return
    }

    setTimeout(() => {
      new Notification("Task Reminder", {
        body: `Don't forget: ${taskTitle}`,
        icon: "/icon-192.png",
        badge: "/icon-192.png",
        vibrate: [200, 100, 200, 100, 200],
        tag: "task-reminder",
        requireInteraction: true
      })
    }, minutes * 60 * 1000)
  }

  updateStatus(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
    }
  }
}
