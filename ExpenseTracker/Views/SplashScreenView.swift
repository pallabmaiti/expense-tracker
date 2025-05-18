//
//  SplashScreenView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 27/03/25.
//

import SwiftUI

/// A view that represents the splash screen of the application.
///
/// This view is displayed initially when the app launches. It shows a logo and the app's name ("Expense Tracker"),
/// with a fade-out animation before transitioning to the main content view (i.e., `ContentView`).
/// The splash screen lasts for 1 second before transitioning to the main screen.
///
/// - **Appearance**:
///   - The splash screen background color changes based on the system's color scheme (dark or light mode).
///   - A logo is displayed at the center with a fade-out animation.
///   - The app's name "Expense Tracker" is shown below the logo.
struct SplashScreenView: View {
    /// An instance of `Authenticator` that handles authentication and user state.
    /// Using `@State` keeps it alive during the lifetime of the scene.
    @State private var authenticator = FirebaseAuthenticator()
    
    /// State variable holding the current database switcher instance.
    /// This determines which database (in-memory, local, Firebase) the app should use.
    @State private var databaseManager = DatabaseManager(databaseHandler: DatabaseHandlerImpl())
    
    /// An instance of `TabManager` that tracks the selected tab index throughout the app.
    ///
    /// It's marked with `@State` to maintain its lifecycle and ensure it stays alive across view updates.
    /// It's injected into the environment so any view in the app hierarchy can access and modify it.
    @State private var tabManager = TabManager()
    
    /// Handles all local notification scheduling and permission logic.
    @State private var notificationManager = NotificationManager(center: .init(), settings: NotificationSettingsHandler())
    
    /// A state variable that determines whether the splash screen should be active or not.
    /// When `isActive` is true, the main `ExpenseListView` is shown.
    @State private var isActive = false
    
    /// The current color scheme of the system (dark or light mode).
    /// Used to adjust the background color of the splash screen.
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        // If the splash screen is not active, show the splash screen with logo and app name.
        if isActive {
            // Transition to the main content view once the splash screen is done.
            /// - `.environment(tabManager)` injects the `TabManager` into the view hierarchy.
            /// - `.environment(authenticator)` injects the `FirebaseAuthenticator` into the view hierarchy.
            /// - `.environment(databaseManager)` injects the `DatabaseManager` into the view hierarchy.
            
            ContentView()
                .task {
                    Task {
                        let isAuthorized = await notificationManager.requestPermission()
                        if isAuthorized {
                            await notificationManager.scheduleDailyExpenseNotification()
                        }
                    }
                }
                .environment(databaseManager)
                .environment(\.authenticator, authenticator)
                .environmentObject(tabManager)
                .environment(notificationManager)
        } else {
            ZStack {
                // Set background color based on color scheme (dark or light mode).
                (colorScheme == .dark ? Color.black : Color.white)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Logo image that fades out when the splash screen transitions.
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .opacity(isActive ? 0 : 1)  // Fades out when isActive becomes true.
                        .animation(.easeInOut(duration: 0.5), value: isActive)  // Animation duration: 0.5 seconds.
                    // App title text.
                    Text("Expense Tracker")
                        .font(.title.bold())  // Large, bold font for the app name.
                        .foregroundStyle(colorScheme == .dark ? .white : .green1)  // Custom text color.
                }
            }
            .onAppear {
                // After 1 second, set isActive to true to trigger the transition to the main screen.
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isActive = true
                }
            }
        }
    }
}


#Preview {
    SplashScreenView()
}
