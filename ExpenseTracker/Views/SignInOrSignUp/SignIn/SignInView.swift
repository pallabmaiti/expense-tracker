//
//  SignInView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 18/04/25.
//

import SwiftUI

/// A view that presents the sign-in screen with options for email and Google sign-in.
struct SignInView: View {
    /// The view model managing the sign-in logic and state.
    @State private var viewModel: ViewModel

    /// The user provider handling authentication logic.
    var userProvider: UserProvider

    /// A closure executed when the user taps "Sign up".
    var onSignUp: () -> Void

    /// Initializes the `SignInView` with a user provider and sign-up callback.
    /// - Parameters:
    ///   - userProvider: The provider handling sign-in operations.
    ///   - onSignUp: A closure triggered when the user selects sign-up.
    init(userProvider: UserProvider, onSignUp: @escaping () -> Void) {
        self.userProvider = userProvider
        self._viewModel = .init(wrappedValue: .init(userProvider: userProvider))
        self.onSignUp = onSignUp
    }
    
    var body: some View {
        if viewModel.isVerifying {
            VerifyOTPView(
                title: "Check your email",
                subtitle: "to continue with sign in",
                userProvider: userProvider
            ) {
                withAnimation {
                    viewModel.isVerifying = false
                }
            }
            .transition(.slide.combined(with: .opacity))
        } else {
            VStack {
                Text("Welcome back!")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .lineLimit(1)
                Text("Please sign in to continue")
                    .font(.title3)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                
                SocialSignInView() {
                    Task { await viewModel.signInWithGoogle() }
                }
                .padding(.top)
                
                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(.secondary.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .cornerRadius(10)
                    .padding(.top, 20)
                
                
                PrimaryButton("Send OTP", isEnabled: !viewModel.email.isEmpty) {
                    Task { await viewModel.signIn() }
                }
                .padding(.top, 30)
                
                HStack {
                    Text("Don't have an account?")
                    
                    Button("Sign up", action: onSignUp)
                    
                    Spacer()
                }
                .padding(.vertical)
                
                Spacer()
            }
            .padding()
            .transition(.slide.combined(with: .opacity))
            .alert("Error", isPresented: $viewModel.showError) {
                Button("Ok") {
                    
                }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

#Preview {
    SignInView(userProvider: ClerkUserProvider()) { }
}
