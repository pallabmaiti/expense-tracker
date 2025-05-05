//
//  SignInOrSignUpView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 19/04/25.
//

import SwiftUI

/// A view that toggles between the Sign In and Sign Up screens.
///
/// This view uses an internal state to switch between sign-in and sign-up modes,
/// and provides animated transitions between them.
struct SignInOrSignUpView: View {
    @Environment(DatabaseManager.self) private var databaseManager
    
    @Environment(\.dismiss) private var dismiss
    /// The shared `UserProvider` from the environment for authentication operations.
    @Environment(\.userProvider) private var userProvider

    /// A flag indicating whether the view is currently showing the sign-in screen.
    @State private var isSignInMode: Bool = false
    
    @State private var isLoading = false

    var userAuthenticated: (() -> Void)

    var body: some View {
        if isSignInMode {
            /// Displays the SignInView when in sign-in mode.
            SignInView(userProvider: userProvider, onSignUp: {
                // Toggle back to sign-up mode with animation.
                withAnimation {
                    isSignInMode.toggle()
                }
            }, userAuthenticated: {
                Task {
                    await syncData()
                }
                userAuthenticated()
                dismiss()
            })
            .transition(.slide.combined(with: .opacity)) // Adds animation during view switch.
            .progressHUD(isShowing: $isLoading, title: .constant("Syncing..."))
        } else {
            /// Displays the SignUpView when in sign-up mode.
            SignUpView(userProvider: userProvider, onSignIn: {
                // Toggle to sign-in mode with animation.
                withAnimation {
                    isSignInMode.toggle()
                }
            }, userAuthenticated: {
                Task {
                    await syncData()
                }
                userAuthenticated()
                dismiss()
            })
            .transition(.slide.combined(with: .opacity)) // Adds animation during view switch.
            .progressHUD(isShowing: $isLoading, title: .constant("Syncing..."))
        }
    }
    
    private func syncData() async {
        if let user = userProvider.user {
            isLoading = true
            UserDefaults.standard.databaseType = .firebase(user.id)
            UserDefaults.standard.isSignedIn = true
            databaseManager.initializeRemoteDatabaseHandler(DatabaseHandlerImpl(database: FirebaseDatabase(userId: user.id)))
            await databaseManager.syncLocalWithRemote()
            await databaseManager.syncRemoteWithLocal()
            isLoading = false
        }
    }
}

#Preview {
    SignInOrSignUpView() { }
        .environment(\.userProvider, ClerkUserProvider())
}
