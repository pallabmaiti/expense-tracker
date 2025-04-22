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
    /// The shared `UserProvider` from the environment for authentication operations.
    @Environment(UserProvider.self) var userProvider

    /// A flag indicating whether the view is currently showing the sign-in screen.
    @State private var isSignInMode: Bool = false

    var body: some View {
        if isSignInMode {
            /// Displays the SignInView when in sign-in mode.
            SignInView(userProvider: userProvider) {
                // Toggle back to sign-up mode with animation.
                withAnimation {
                    isSignInMode.toggle()
                }
            }
            .transition(.slide.combined(with: .opacity)) // Adds animation during view switch.
        } else {
            /// Displays the SignUpView when in sign-up mode.
            SignUpView(userProvider: userProvider) {
                // Toggle to sign-in mode with animation.
                withAnimation {
                    isSignInMode.toggle()
                }
            }
            .transition(.slide.combined(with: .opacity)) // Adds animation during view switch.
        }
    }
}

#Preview {
    SignInOrSignUpView()
        .environment(UserProvider())
}
