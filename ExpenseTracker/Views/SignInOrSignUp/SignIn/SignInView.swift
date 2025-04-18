//
//  SignInView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 18/04/25.
//

import SwiftUI

struct SignInView: View {
    @State private var viewModel: ViewModel
    
    var userProvider: UserProvider
    var onSignUp: () -> Void
    
    init(userProvider: UserProvider, onSignUp: @escaping () -> Void) {
        self.userProvider = userProvider
        _viewModel = .init(wrappedValue: .init(userProvider: userProvider))
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
    SignInView(userProvider: UserProvider()) { }
}
