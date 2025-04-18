//
//  VerifyOTPView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 20/04/25.
//

import SwiftUI

struct VerifyOTPView: View {
    @State private var viewModel: ViewModel
    
    var title: String
    var subtitle: String
    var userProvider: UserProvider
    var close: () -> Void
    
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
                Button {
                    close()
                } label: {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .padding()
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                Text(subtitle)
                    .font(.title3)
                    .padding(.horizontal)
                
                OTPView(otpCode: $viewModel.otpCode)
                    .padding()
                
                PrimaryButton("Verify", isEnabled: viewModel.otpCode.count == 6) {
                    Task {
                        await viewModel.verifyOTP()
                    }
                }
                .padding()
                
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
            .alert("Error", isPresented: $viewModel.showError) {
                Button("Ok") { }
            } message: {
                Text(viewModel.errorMessage)
            }
            
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
    VerifyOTPView(title: "Check your email", subtitle: "to continue with sign up", userProvider: UserProvider()) { }
}
