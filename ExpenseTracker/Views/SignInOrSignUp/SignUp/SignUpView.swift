//
//  SignUpView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 18/04/25.
//

import SwiftUI

/// A reusable form view for capturing user sign-up details.
struct SignUpForm: View {
    /// The user's first name (bound to a parent view's state).
    @Binding var firstName: String
    
    /// The user's last name (bound to a parent view's state).
    @Binding var lastName: String
    
    /// The user's email address (bound to a parent view's state).
    @Binding var email: String
    
    /// A closure executed when the user taps the "Continue" button.
    var action: () -> Void
    
    var body: some View {
        VStack {
            VStack {
                TextField("First Name", text: $firstName)
                    .padding()
                
                Divider()
                    .padding(.horizontal)
                
                TextField("Last Name", text: $lastName)
                    .padding()
                Divider()
                    .padding(.horizontal)
                
                TextField("Email*", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .padding()
                Divider()
                    .padding(.horizontal)
            }
            .background(.secondary.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .cornerRadius(10)
            
            PrimaryButton("Continue", isEnabled: !email.isEmpty, action: action)
                .padding(.top, 30)
        }
    }
}

/// A view that handles the sign-up process, including form-based and social sign-in,
/// and OTP verification once the sign-up is initiated.
struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    
    /// The environment-injected instance of `DatabaseManager`.
    @Environment(DatabaseManager.self) var databaseManager
    
    /// The view model that manages sign-up state and logic.
    @State private var viewModel: ViewModel
    
    /// The user provider used to perform sign-up and authentication tasks.
    var userProvider: UserProvider
    
    /// Callback executed when the user taps "Sign in" (for users who already have an account).
    var onSignIn: () -> Void
    
    var userAuthenticated: (() -> Void)
    
    /// Initializes the sign-up view with dependencies.
    /// - Parameters:
    ///   - userProvider: A shared user provider instance to handle auth logic.
    ///   - onSignIn: A closure that switches to the sign-in view.
    init(userProvider: UserProvider, onSignIn: @escaping () -> Void, userAuthenticated: @escaping () -> Void) {
        self.userProvider = userProvider
        _viewModel = .init(wrappedValue: .init(userProvider: userProvider))
        self.onSignIn = onSignIn
        self.userAuthenticated = userAuthenticated
    }
    
    var body: some View {
        VStack {
            if viewModel.isVerifying {
                VerifyOTPView(
                    title: "Check your email",
                    subtitle: "to continue with sign up",
                    userProvider: userProvider,
                    databaseManager: databaseManager
                ) {
                    withAnimation {
                        viewModel.isVerifying = false
                    }
                } onVerificationSuccess: {
                    userAuthenticated()
                }
                .transition(.slide.combined(with: .opacity))
            } else {
                VStack(alignment: .leading) {
                    Text("Create your account")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding([.top, .horizontal], 20)
                    Text("to sync your data in cloud")
                        .font(.title3)
                        .padding(.horizontal, 20)
                    
                    VStack {
                        SocialSignInView {
                            Task {
                                await viewModel.signUpWithGoogle()
                                userAuthenticated()
                            }
                        }
                        .padding([.top, .horizontal])
                        
                        SignUpForm(
                            firstName: $viewModel.firstName,
                            lastName: $viewModel.lastName,
                            email: $viewModel.email,
                        ) {
                            Task { await viewModel.signUp() }
                        }
                        .padding()
                        
                        HStack {
                            Text("Already have an account?")
                            
                            Button("Sign in", action: onSignIn)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }
                .alert("Error", isPresented: $viewModel.showError) {
                    Button("Ok") {
                        
                    }
                } message: {
                    Text(viewModel.errorMessage)
                }
                .transition(.slide.combined(with: .opacity))
            }
        }
    }
}

#Preview {
    SignUpView(userProvider: ClerkUserProvider()) { } userAuthenticated: { }
        .environment(
            DatabaseManager(
                databaseHandler: DatabaseHandlerImpl(
                    database: InMemoryDatabase()
                )
            )
        )
}
