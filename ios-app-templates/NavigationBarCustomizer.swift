//
//  NavigationBarCustomizer.swift
//  PlanMyDay
//
//  Customizes navigation bar appearance to match brand
//

import UIKit
import Foundation

class NavigationBarCustomizer {

    static func setupAppearance() {
        // Navigation Bar Appearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()

        // Background color - white with slight tint
        navigationBarAppearance.backgroundColor = .systemBackground

        // Title text attributes (color and font)
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: Configuration.primaryColor,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]

        // Large title attributes (for scrolling pages)
        navigationBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: Configuration.primaryColor,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]

        // Tint color for buttons (back button, etc.)
        UINavigationBar.appearance().tintColor = Configuration.primaryColor

        // Apply appearance
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance

        if #available(iOS 15.0, *) {
            UINavigationBar.appearance().compactScrollEdgeAppearance = navigationBarAppearance
        }

        // Make navigation bar not translucent for solid look
        UINavigationBar.appearance().isTranslucent = false
    }
}
