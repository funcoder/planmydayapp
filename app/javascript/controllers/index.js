// Load all the controllers within this directory and all subdirectories.
// Controller files must be named *_controller.js.

import { application } from "controllers/application"

// Brain Dump
import BrainDumpController from "controllers/brain_dump_controller.js"
application.register("brain-dump", BrainDumpController)

// Cookie Consent
import CookieConsentController from "controllers/cookie_consent_controller.js"
application.register("cookie-consent", CookieConsentController)

// Dropdown
import DropdownController from "controllers/dropdown_controller.js"
application.register("dropdown", DropdownController)

// Hello
import HelloController from "controllers/hello_controller.js"
application.register("hello", HelloController)

// Mobile Menu
import MobileMenuController from "controllers/mobile_menu_controller.js"
application.register("mobile-menu", MobileMenuController)

// Notifications
import NotificationsController from "controllers/notifications_controller.js"
application.register("notifications", NotificationsController)

// Pomodoro
import PomodoroController from "controllers/pomodoro_controller.js"
application.register("pomodoro", PomodoroController)

// PWA Install
import PwaInstallController from "controllers/pwa_install_controller.js"
application.register("pwa-install", PwaInstallController)

// Service Worker
import ServiceWorkerController from "controllers/service_worker_controller.js"
application.register("service-worker", ServiceWorkerController)

// Task
import TaskController from "controllers/task_controller.js"
application.register("task", TaskController)

// User Menu
import UserMenuController from "controllers/user_menu_controller.js"
application.register("user-menu", UserMenuController)
