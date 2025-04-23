//
//  SignUpViewModelTests.swift
//  ExpenseTrackerTests
//
//  Created by Pallab Maiti on 22/04/25.
//

import Testing
@testable import ExpenseTracker

@MainActor
@Suite("SignUpViewModel Tests")
struct SignUpViewModelTests {
    var viewModel: SignUpView.ViewModel
    var userProvider: MockUserProvider
    
    init() async throws {
        userProvider = MockUserProvider()
        viewModel = .init(userProvider: userProvider)
    }

    @Test("Sign up - Success")
    func signUpSuccess() async throws {
        await viewModel.signUp()
        
        #expect(viewModel.isVerifying == true)
        #expect(viewModel.showError == false)
        #expect(viewModel.errorMessage == "")
    }
    
    @Test("Sign up - Failure")
    func signUpFailure() async throws {
        userProvider.shouldFailSignUp = true
        await viewModel.signUp()
        
        #expect(viewModel.isVerifying == false)
        #expect(viewModel.showError == true)
        #expect(viewModel.errorMessage == "Sign up failed")
    }
    
    @Test("Sign up with Google - Success")
    func signUpWithGoogleSuccess() async throws {
        await viewModel.signUpWithGoogle()
        
        #expect(viewModel.showError == false)
        #expect(viewModel.errorMessage == "")
    }
    
    @Test("Sign up with Google - Failure")
    func signUpWithGoogleFailure() async throws {
        userProvider.shouldFailGoogleSignIn = true
        await viewModel.signUpWithGoogle()
        
        #expect(viewModel.showError == true)
        #expect(viewModel.errorMessage == "Google sign in failed")
    }
}
