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
    /// Environment-injected user provider used for authentication and user state management.
    @Environment(\.userProvider) var userProvider
    
    /// State variable holding the current database switcher instance.
    /// This determines which database (in-memory, local, Firebase) the app should use.
    @State private var databaseManager = DatabaseManager(databaseHandler: DatabaseHandlerImpl())
    
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
            ContentView()
                .environment(databaseManager)
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
        .environmentObject(TabManager())
}
