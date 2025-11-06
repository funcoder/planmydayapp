//
//  SceneDelegate.swift
//  PlanMyDay
//
//  Hotwire Native Scene Delegate with Loading Screen
//

import UIKit
import HotwireNative
import WebKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var loadingViewController: LoadingViewController?
    private var hasFinishedInitialLoad = false

    // Single navigator
    private lazy var navigator: Navigator = {
        let nav = Navigator(
            configuration: Navigator.Configuration(
                name: "main",
                startLocation: Configuration.serverURL
            )
        )
        return nav
    }()

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

        // Set root view controller
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        // Show loading screen
        showLoadingScreen()

        // Start the navigator
        navigator.start()

        // Monitor web view loading and dismiss loading screen when done
        observeWebViewLoading()
    }

    private func showLoadingScreen() {
        guard let window = window else { return }

        loadingViewController = LoadingViewController()
        loadingViewController?.view.frame = window.bounds

        if let loadingView = loadingViewController?.view {
            window.addSubview(loadingView)
        }
    }

    private func observeWebViewLoading() {
        // Check for webview every 0.5 seconds
        var checkCount = 0
        let maxChecks = 20 // Max 10 seconds

        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            checkCount += 1

            // Find the webview in the navigator
            if let navController = self.navigator.rootViewController as? UINavigationController,
               let webView = self.findWebView(in: navController.view) {

                // Check if page is loaded
                if !webView.isLoading {
                    timer.invalidate()
                    self.hideLoadingScreen()
                    return
                }
            }

            // Timeout after max checks
            if checkCount >= maxChecks {
                timer.invalidate()
                self.hideLoadingScreen()
            }
        }
    }

    private func findWebView(in view: UIView) -> WKWebView? {
        if let webView = view as? WKWebView {
            return webView
        }

        for subview in view.subviews {
            if let webView = findWebView(in: subview) {
                return webView
            }
        }

        return nil
    }

    private func hideLoadingScreen() {
        guard let loadingVC = loadingViewController, !hasFinishedInitialLoad else { return }

        hasFinishedInitialLoad = true

        // Delay slightly to ensure content is visible
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            loadingVC.dismiss {
                loadingVC.view.removeFromSuperview()
                self.loadingViewController = nil
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Reload when app becomes active (only if not initial load)
        if hasFinishedInitialLoad {
            navigator.reload()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
