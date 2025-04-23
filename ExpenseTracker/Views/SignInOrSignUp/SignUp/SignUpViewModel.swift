//
//  SignUpViewModel.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 19/04/25.
//

import Foundation

extension SignUpView {
    /// ViewModel that handles the sign-up logic and state management for `SignUpView`.
    @Observable
    class ViewModel {
        // MARK: - User Input
        
        /// User's first name input from the sign-up form.
        var firstName: String = ""
        
        /// User's last name input from the sign-up form.
        var lastName: String = ""
        
        /// User's email input from the sign-up form.
        var email: String = ""
        
        // MARK: - State Properties
        
        /// A flag indicating whether the user is in the OTP verification phase.
        var isVerifying: Bool = false
        
        /// Stores an error message to display in the UI if sign-up fails.
        var errorMessage: String = ""
        
        /// A flag that triggers the display of an alert if an error occurs.
        var showError: Bool = false
        
        /// The user provider responsible for sign-up and authentication requests.
        var userProvider: UserProvider
        
        // MARK: - Initialization
        
        /// Initializes the view model with the given user provider.
        /// - Parameter userProvider: The shared instance responsible for performing auth operations.
        init(userProvider: UserProvider) {
            self.userProvider = userProvider
        }
        
        // MARK: - Sign Up Actions
        
        /// Initiates sign-up with Google account.
        /// Displays an error alert if the process fails.
        func signUpWithGoogle() async {
            do {
                try await userProvider.signInWithGoogle()
            } catch {
                showError = true
                errorMessage = error.localizedErrorMessage
            }
        }
        
        /// Performs form-based sign-up using email, first name, and last name.
        /// Transitions to OTP verification on success.
        func signUp() async {
            do {
                try await userProvider.signUp(
                    emailAddress: email,
                    firstName: firstName,
                    lastName: lastName
                )
                isVerifying = true
            } catch {
                showError = true
                errorMessage = error.localizedErrorMessage
            }
        }
    }
}

