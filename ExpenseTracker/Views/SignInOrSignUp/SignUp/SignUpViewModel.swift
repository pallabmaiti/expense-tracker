//
//  SignUpViewModel.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 19/04/25.
//

import Foundation

extension SignUpView {
    @Observable
    class ViewModel {
        var firstName: String = ""
        var lastName: String = ""
        var email: String = ""
        
        var isVerifying: Bool = false
        var errorMessage: String = ""
        var showError: Bool = false

        var userProvider: UserProvider
        
        init (userProvider: UserProvider) {
            self.userProvider = userProvider
        }
        
        func signUpWithGoogle() async {
            do {
                try await userProvider.signInWithGoogle()
            } catch {
                showError = true
                errorMessage = error.localizedErrorMessage
            }
        }
        
        func signUp() async {
            do {
                try await userProvider.signUp(emailAddress: email, firstName: firstName, lastName: lastName)
                isVerifying = true
            } catch {
                showError = true
                errorMessage = error.localizedErrorMessage
            }
        }
    }
}
