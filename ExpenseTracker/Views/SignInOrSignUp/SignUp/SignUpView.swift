//
//  SignUpView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 18/04/25.
//

import SwiftUI

struct SignUpForm: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var email: String
    
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

struct SignUpView: View {
    @State private var viewModel: ViewModel
    
    var userProvider: UserProvider
    var onSignIn: () -> Void
    
    init(userProvider: UserProvider, onSignIn: @escaping () -> Void) {
        self.userProvider = userProvider
        _viewModel = .init(wrappedValue: .init(userProvider: userProvider))
        self.onSignIn = onSignIn
    }
    
    var body: some View {
        VStack {
            if viewModel.isVerifying {
                VerifyOTPView(
                    title: "Check your email",
                    subtitle: "to continue with sign up",
                    userProvider: userProvider
                ) {
                    withAnimation {
                        viewModel.isVerifying = false
                    }
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
                            Task { await viewModel.signUpWithGoogle() }
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
    SignUpView(userProvider: UserProvider()) { }
}
