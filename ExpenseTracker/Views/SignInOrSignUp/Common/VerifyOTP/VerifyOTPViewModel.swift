//
//  VerifyOTPViewModel.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 21/04/25.
//

import Foundation


extension VerifyOTPView {
    @Observable
    class ViewModel {
        var otpCode: String = ""
        var errorMessage: String = ""
        var showError: Bool = false

        var userProvider: UserProvider
        
        init(userProvider: UserProvider) {
            self.userProvider = userProvider
        }
        
        func verifyOTP() async {
            do {
                try await userProvider.verifyOTP(otpCode)
            } catch {
                showError = true
                errorMessage = error.localizedErrorMessage
            }
        }
        
        func resendOTP() async {
            do {
                try await userProvider.resendOTP()
            } catch {
                showError = true
                errorMessage = error.localizedDescription
            }
        }
    }
}
