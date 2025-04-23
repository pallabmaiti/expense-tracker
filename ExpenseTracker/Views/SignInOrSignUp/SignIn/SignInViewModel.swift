//
//  SignInViewModel.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 19/04/25.
//

import Foundation

extension SignInView {
    /// ViewModel for handling sign-in logic and state for `SignInView`.
    ///
    /// Supports both email-based sign-in and Google OAuth sign-in using `UserProvider`.
    @Observable
    class ViewModel {
        
        /// Email address input from the user.
        var email: String = ""
        
        /// Error message to display in case of failure.
        var errorMessage: String = ""
        
        /// Flag to show verification screen (e.g., OTP entry) after email sign-in initiation.
        var isVerifying = false
        
        /// Flag to toggle display of an error alert.
        var showError: Bool = false
        
        /// User provider instance for authentication actions.
        var userProvider: UserProvider
        
        /// Initializes the view model with a `UserProvider`.
        init(userProvider: UserProvider) {
            self.userProvider = userProvider
        }
        
        /// Initiates Google OAuth sign-in flow.
        ///
        /// If the sign-in fails, sets appropriate error state.
        func signInWithGoogle() async {
            do {
                try await userProvider.signInWithGoogle()
            } catch {
                showError = true
                errorMessage = error.localizedErrorMessage
            }
        }
        
        /// Initiates email-based sign-in and sets `isVerifying` to `true` if successful.
        ///
        /// If the sign-in fails, sets appropriate error state.
        func signIn() async {
            do {
                try await userProvider.signIn(email: email)
                isVerifying = true
            } catch {
                showError = true
                errorMessage = error.localizedErrorMessage
            }
        }
    }
}
