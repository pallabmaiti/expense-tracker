//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 27/03/25.
//

import SwiftUI

/// The main entry point of the Expense Tracker application.
///
/// This struct conforms to the `App` protocol, which defines the structure and behavior
/// of the app. The `@main` attribute indicates that this is the starting point.
@main
struct ExpenseTrackerApp: App {
    @State private var userProvider = UserProvider()

    /// An instance of `TabManager` that tracks the selected tab index throughout the app.
    ///
    /// It's marked with `@State` to maintain its lifecycle and ensure it stays alive across view updates.
    /// It's injected into the environment so any view in the app hierarchy can access and modify it.
    @State private var tabManager = TabManager()
    
    /// The body that defines the scene (UI container) for the app.
    ///
    /// - `WindowGroup` creates a scene that presents a window for the app’s content.
    /// - `SplashScreenView` is the initial view shown when the app launches.
    /// - `.environmentObject(tabManager)` injects the `TabManager` into the view hierarchy.
    var body: some Scene {
        WindowGroup {
            ZStack {
                if userProvider.isLoaded {
                    SplashScreenView()
                } else {
                    ProgressView()
                }
            }
            .environmentObject(tabManager)
            .environment(userProvider)
            .task {
                do {
                    try await userProvider.load()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
