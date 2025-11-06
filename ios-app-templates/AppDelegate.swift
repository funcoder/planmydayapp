//
//  AppDelegate.swift
//  PlanMyDay
//
//  Hotwire Native App Delegate
//

import UIKit
import HotwireNative

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Load path configuration from server
        Hotwire.loadPathConfiguration(from: [.server(Configuration.pathConfigurationURL)])

        // Enable debug logging in development
        if Configuration.enableDebugLogging {
            Hotwire.config.debugLoggingEnabled = true
        }

        // Request push notification permissions if enabled
        if Configuration.enablePushNotifications {
            PushNotificationManager.shared.requestAuthorization()
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    // MARK: Push Notifications

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if Configuration.enablePushNotifications {
            PushNotificationManager.shared.didRegisterForRemoteNotifications(deviceToken: deviceToken)
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
}
