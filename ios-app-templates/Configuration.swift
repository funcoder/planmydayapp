//
//  Configuration.swift
//  PlanMyDay
//
//  Hotwire Native Configuration
//

import Foundation
import UIKit

struct Configuration {
    // MARK: - Server Configuration

    // Development: Use localhost
    static let serverURL = URL(string: "http://localhost:3000")!

    // Production: Use your deployed app URL
    // static let serverURL = URL(string: "https://planmyday-app.fly.dev")!

    // Path to server-hosted path configuration
    static let pathConfigurationURL = URL(string: "\(serverURL.absoluteString)/path-configuration.json")!

    // MARK: - App Configuration

    static let appName = "PlanMyDay"

    // MARK: - Theme Colors (matching your Rails app)

    // Primary color: Teal (#14b8a6 / rgb(20, 184, 166))
    static let primaryColor = UIColor(red: 20/255, green: 184/255, blue: 166/255, alpha: 1.0)

    // Secondary color: Purple (#8b5cf6 / rgb(139, 92, 246))
    static let secondaryColor = UIColor(red: 139/255, green: 92/255, blue: 246/255, alpha: 1.0)

    // Accent color: For highlights
    static let accentColor = UIColor(red: 236/255, green: 72/255, blue: 153/255, alpha: 1.0)

    // MARK: - Feature Flags

    static let enablePushNotifications = true
    static let enableDebugLogging = true
}
