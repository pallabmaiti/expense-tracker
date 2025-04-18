//
//  SignInOrSignUpView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 19/04/25.
//

import SwiftUI

struct SignInOrSignUpView: View {
    @Environment(UserProvider.self) var userProvider
    @State private var isSignInMode: Bool = false
    
    var body: some View {
        if isSignInMode {
            SignInView(userProvider: userProvider) {
                withAnimation {
                    isSignInMode.toggle()
                }
            }
            .transition(.slide.combined(with: .opacity))
        } else {
            SignUpView(userProvider: userProvider) {
                withAnimation {
                    isSignInMode.toggle()
                }
            }
            .transition(.slide.combined(with: .opacity))
        }
    }
}

#Preview {
    SignInOrSignUpView()
        .environment(UserProvider())
}
