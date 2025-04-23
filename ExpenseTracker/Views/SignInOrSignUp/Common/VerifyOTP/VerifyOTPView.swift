//
//  VerifyOTPView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 20/04/25.
//

import SwiftUI

/// A view for verifying a one-time password (OTP) sent to the user's email.
///
/// Includes an OTP input field, verification button, and a way to resend the OTP if needed.
/// Also handles loading state and error alerts.
struct VerifyOTPView: View {
    
    /// ViewModel responsible for OTP verification and resend logic.
    @State private var viewModel: ViewModel
    
    /// The title displayed at the top of the view.
    var title: String
    
    /// The subtitle (usually describing the action or email target).
    var subtitle: String
    
    /// Instance of `UserProvider` for performing backend verification.
    var userProvider: UserProvider
    
    /// Callback to close/dismiss the view.
    var close: () -> Void
    
    /// Custom initializer to set properties and initialize the ViewModel.
    init(title: String, subtitle: String, userProvider: UserProvider, close: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.userProvider = userProvider
        self._viewModel = .init(wrappedValue: .init(userProvider: userProvider))
        self.close = close
    }
    
    var body: some View {
        ZStack {
            VStack {
                
                // Close button
                Button {
                    close()
                } label: {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .padding()
                
                // Main title
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                // Subtitle for context (e.g. “Enter the OTP sent to your email”)
                Text(subtitle)
                    .font(.title3)
                    .padding(.horizontal)
                
                // OTP input view
                OTPView(otpCode: $viewModel.otpCode)
                    .padding()
                
                // "Verify" button - only enabled when 6 digits are entered
                PrimaryButton("Verify", isEnabled: viewModel.otpCode.count == 6) {
                    Task {
                        await viewModel.verifyOTP()
                    }
                }
                .padding()
                
                // Resend code prompt
                HStack {
                    Text("Didn't receive the code?")
                    
                    Button("Resend") {
                        Task {
                            await viewModel.resendOTP()
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                Spacer()
            }
            // Alert shown on error
            .alert("Error", isPresented: $viewModel.showError) {
                Button("Ok") { }
            } message: {
                Text(viewModel.errorMessage)
            }
            
            // Full-screen loader shown when `userProvider.isLoading` is true
            if userProvider.isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(2.5)
                        .tint(.green1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.9))
            }
        }
    }
}

#Preview {
    VerifyOTPView(title: "Check your email", subtitle: "to continue with sign up", userProvider: ClerkUserProvider()) { }
}
