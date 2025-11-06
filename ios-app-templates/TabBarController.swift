//
//  TabBarController.swift
//  PlanMyDay
//
//  Native tab bar with Dashboard, Tasks, Brain Dump, and Profile
//

import UIKit
import Foundation
import HotwireNative

class TabBarController: UITabBarController {

    // MARK: - Navigators for Each Tab

    private lazy var dashboardNavigator = Navigator(
        configuration: Navigator.Configuration(
            name: "dashboard",
            startLocation: Configuration.dashboardURL
        )
    )

    private lazy var tasksNavigator = Navigator(
        configuration: Navigator.Configuration(
            name: "tasks",
            startLocation: Configuration.tasksURL
        )
    )

    private lazy var brainDumpNavigator = Navigator(
        configuration: Navigator.Configuration(
            name: "braindump",
            startLocation: Configuration.brainDumpURL
        )
    )

    private lazy var profileNavigator = Navigator(
        configuration: Navigator.Configuration(
            name: "profile",
            startLocation: Configuration.profileURL
        )
    )

    // MARK: - Initialization

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        customizeAppearance()
    }

    // MARK: - Tab Setup

    private func setupTabs() {
        // Dashboard Tab
        let dashboardVC = dashboardNavigator.rootViewController
        dashboardVC.tabBarItem = UITabBarItem(
            title: "Dashboard",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        // Tasks Tab
        let tasksVC = tasksNavigator.rootViewController
        tasksVC.tabBarItem = UITabBarItem(
            title: "Tasks",
            image: UIImage(systemName: "checklist"),
            selectedImage: UIImage(systemName: "checklist")
        )

        // Brain Dump Tab
        let brainDumpVC = brainDumpNavigator.rootViewController
        brainDumpVC.tabBarItem = UITabBarItem(
            title: "Brain Dump",
            image: UIImage(systemName: "brain.head.profile"),
            selectedImage: UIImage(systemName: "brain.head.profile")
        )

        // Profile Tab
        let profileVC = profileNavigator.rootViewController
        profileVC.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )

        // Set view controllers
        viewControllers = [dashboardVC, tasksVC, brainDumpVC, profileVC]

        // Start all navigators
        dashboardNavigator.start()
        tasksNavigator.start()
        brainDumpNavigator.start()
        profileNavigator.start()

        // Select dashboard by default
        selectedIndex = 0
    }

    // MARK: - Appearance Customization

    private func customizeAppearance() {
        // Tab Bar Appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .systemBackground

        // Selected tab color (your primary color)
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = Configuration.primaryColor
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: Configuration.primaryColor
        ]

        // Normal tab color
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .systemGray
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray
        ]

        tabBar.standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = tabBarAppearance
        }
    }
}
