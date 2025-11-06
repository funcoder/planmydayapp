//
//  PushNotificationManager.swift
//  PlanMyDay
//
//  Manages push notifications and device token registration
//

import Foundation
import UIKit
import UserNotifications

class PushNotificationManager: NSObject {

    static let shared = PushNotificationManager()

    private var deviceToken: String?

    private override init() {
        super.init()
    }

    // MARK: - Authorization

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Push notification permission granted")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else if let error = error {
                print("Push notification permission error: \(error.localizedDescription)")
            } else {
                print("Push notification permission denied")
            }
        }
    }

    // MARK: - Device Token Registration

    func didRegisterForRemoteNotifications(deviceToken: Data) {
        // Convert device token to string
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        self.deviceToken = tokenString

        print("Device token: \(tokenString)")

        // Register with Rails backend
        registerDeviceTokenWithBackend(token: tokenString)
    }

    private func registerDeviceTokenWithBackend(token: String) {
        guard let url = URL(string: "\(Configuration.serverURL.absoluteString)/api/v1/device_tokens") else {
            print("Invalid device token registration URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = [
            "token": token,
            "platform": "ios"
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            print("Error serializing device token: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error registering device token: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 201 {
                    print("Device token registered successfully")
                } else {
                    print("Device token registration failed with status: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension PushNotificationManager: UNUserNotificationCenterDelegate {

    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .badge, .sound])
    }

    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        // Handle notification tap - navigate to specific screen if needed
        if let urlString = userInfo["url"] as? String,
           let url = URL(string: urlString) {
            // Navigate to the URL
            print("Notification tapped - navigate to: \(url)")
        }

        completionHandler()
    }
}
