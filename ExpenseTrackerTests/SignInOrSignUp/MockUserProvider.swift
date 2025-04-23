//
//  MockUserProvider.swift
//  ExpenseTrackerTests
//
//  Created by Pallab Maiti on 22/04/25.
//

import Foundation
@testable import ExpenseTracker

@MainActor
class MockUserProvider: UserProvider {
    private(set) var isLoading: Bool = false
    
    var shouldFailVerify = false
    var shouldFailResend = false
    var shouldFailSignIn = false
    var shouldFailSignUp = false
    var shouldFailSignOut = false
    var shouldFailGoogleSignIn = false
    
    var user: User? {
        .init(id: "123", email: "test@example.com")
    }
    
    func load() async throws {
        
    }
    
    func signIn(email: String) async throws(UserProviderError) {
        if shouldFailSignIn {
            throw .error("Sign in failed")
        }
    }
    
    func signUp(emailAddress: String, firstName: String, lastName: String) async throws(UserProviderError) {
        if shouldFailSignUp {
            throw .error("Sign up failed")
        }
    }
    
    func signInWithGoogle() async throws(UserProviderError) {
        if shouldFailGoogleSignIn {
            throw .error("Google sign in failed")
        }
    }
    
    func signOut() async throws(UserProviderError) {
        if shouldFailSignOut {
            throw .error("Sign out failed")
        }
    }
    
    func verifyOTP(_ code: String) async throws(UserProviderError) {
        if shouldFailVerify || code != "123456" {
            throw .error("Verify OTP failed")
        }
    }
    
    func resendOTP() async throws(UserProviderError) {
        if shouldFailResend {
            throw .error("Resend OTP failed")
        }
    }
}
