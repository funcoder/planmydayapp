//
//  SceneDelegate.swift
//  PlanMyDay
//
//  Hotwire Native Scene Delegate
//

import UIKit
import HotwireNative

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // Single navigator
    private lazy var navigator = Navigator(
        configuration: Navigator.Configuration(
            name: "main",
            startLocation: Configuration.serverURL
        )
    )

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Create window
        window = UIWindow(windowScene: windowScene)

        // Get the navigation controller from the navigator
        let navigationController = navigator.rootViewController

        // Ensure navigation bar is visible and styled
        if let navController = navigationController as? UINavigationController {
            navController.setNavigationBarHidden(false, animated: false)

            // Create and configure navigation bar appearance
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()

            // Set background color with a subtle tint
            appearance.backgroundColor = UIColor.systemBackground

            // Add a subtle shadow to make it more distinct
            appearance.shadowColor = UIColor.systemGray4

            // Title styling with your teal brand color
            appearance.titleTextAttributes = [
                .foregroundColor: Configuration.primaryColor,
                .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
            ]

            // Large title styling (for pages that use it)
            appearance.largeTitleTextAttributes = [
                .foregroundColor: Configuration.primaryColor,
                .font: UIFont.systemFont(ofSize: 34, weight: .bold)
            ]

            // Apply the appearance
            navController.navigationBar.standardAppearance = appearance
            navController.navigationBar.scrollEdgeAppearance = appearance
            navController.navigationBar.compactAppearance = appearance

            if #available(iOS 15.0, *) {
                navController.navigationBar.compactScrollEdgeAppearance = appearance
            }

            // Set tint color for back button and other bar items
            navController.navigationBar.tintColor = Configuration.primaryColor

            // Make sure the bar is not translucent
            navController.navigationBar.isTranslucent = false
        }

        // Set root view controller and show window
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        // Start the navigator
        navigator.start()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Reload when app becomes active
        navigator.reload()
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
