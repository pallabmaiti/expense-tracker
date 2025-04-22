//
//  VerifyOTPViewModelTests.swift
//  ExpenseTrackerTests
//
//  Created by Pallab Maiti on 22/04/25.
//

import Testing
@testable import ExpenseTracker

@MainActor
@Suite("VerifyOTPViewModel Tests")
struct VerifyOTPViewModelTests {
    var viewModel: VerifyOTPView.ViewModel
    var userProvider: MockUserProvider
    
    init() async throws {
        userProvider = MockUserProvider()
        viewModel = .init(userProvider: userProvider)
    }
    
    @Test("Verify OTP - Success")
    func verifyOTPSuccess() async throws {
        viewModel.otpCode = "123456"
        await viewModel.verifyOTP()
        
        #expect(viewModel.showError == false)
        #expect(viewModel.errorMessage == "")
    }
    
    @Test("Verify OTP - Failure")
    func verifyOTPFailure() async throws {
        viewModel.otpCode = "000000"
        await viewModel.verifyOTP()
        
        #expect(viewModel.showError == true)
        #expect(viewModel.errorMessage == "Verify OTP failed")
    }
    
    @Test("Resend OTP - Success")
    func resendOTPSuccess() async throws {
        await viewModel.resendOTP()
        
        #expect(viewModel.showError == false)
        #expect(viewModel.errorMessage == "")
    }
    
    @Test("Resend OTP - Failure")
    func resendOTPFailure() async throws {
        userProvider.shouldFailResend = true
        await viewModel.resendOTP()
        
        #expect(viewModel.showError == true)
        #expect(viewModel.errorMessage == "Resend OTP failed")
    }
}
