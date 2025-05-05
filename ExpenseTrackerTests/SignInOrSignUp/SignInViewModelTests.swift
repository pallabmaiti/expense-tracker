//
//  SignInViewModelTests.swift
//  ExpenseTrackerTests
//
//  Created by Pallab Maiti on 22/04/25.
//

import Testing
@testable import ExpenseTracker

@MainActor
@Suite("SignInViewModel Tests")
struct SignInViewModelTests {
    var viewModel: SignInView.ViewModel
    var userProvider: MockUserProvider
    
    init() async throws {
        userProvider = MockUserProvider()
        viewModel = .init(userProvider: userProvider)
    }

    @Test("Sign in - Success", .tags(.signIn))
    func signInSuccess() async throws {
        await viewModel.signIn()
        
        #expect(viewModel.showError == false)
        #expect(viewModel.errorMessage == "")
    }
    
    @Test("Sign in - Failure", .tags(.signIn))
    func signInFailure() async throws {
        userProvider.shouldFailSignIn = true
        await viewModel.signIn()
        
        #expect(viewModel.showError == true)
        #expect(viewModel.errorMessage == "Sign in failed")
    }
    
    @Test("Sign in with Google - Success", .tags(.signIn))
    func signInWithGoogleSuccess() async throws {
        await viewModel.signInWithGoogle()
        
        #expect(viewModel.showError == false)
        #expect(viewModel.errorMessage == "")
    }
    
    @Test("Sign in with Google - Failure", .tags(.signIn))
    func signInWithGoogleFailure() async throws {
        userProvider.shouldFailGoogleSignIn = true
        await viewModel.signInWithGoogle()
        
        #expect(viewModel.showError == true)
        #expect(viewModel.errorMessage == "Google sign in failed")
    }
}
