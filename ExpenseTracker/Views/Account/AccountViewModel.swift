//
//  AccountViewModel.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 06/05/25.
//

import Foundation

extension AccountView {
    @Observable
    class ViewModel {
        var firstName: String = ""
        var lastName: String = ""

        var errorMessage: String = ""
        
        var showError: Bool = false
        
        var authenticator: Authenticator
        
        var databaseManager: DatabaseManager

        init(authenticator: Authenticator, databaseManager: DatabaseManager) {
            self.authenticator = authenticator
            self.databaseManager = databaseManager
        }
        
        var email: String {
            authenticator.user?.email ?? ""
        }
        
        func signOut() {
            do {
                try authenticator.signOut()
                UserDefaults.standard.databaseType = .local
                UserDefaults.standard.isSignedIn = false
                databaseManager.deinitializeRemoteDatabaseHandler()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}
