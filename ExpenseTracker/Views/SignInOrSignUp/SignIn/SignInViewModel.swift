//
//  SignInViewModel.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 19/04/25.
//

import Foundation

extension SignInView {
    @Observable
    class ViewModel {
        var email: String = ""
        var errorMessage: String = ""
        var isVerifying = false
        var showError: Bool = false
        
        var userProvider: UserProvider
        
        init (userProvider: UserProvider) {
            self.userProvider = userProvider
        }
        
        func signInWithGoogle() async {
            do {
                try await userProvider.signInWithGoogle()
            } catch {
                showError = true
                errorMessage = error.localizedErrorMessage
            }
        }
        
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
