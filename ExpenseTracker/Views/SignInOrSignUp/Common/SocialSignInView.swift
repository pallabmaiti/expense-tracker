//
//  SocialSignInView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 19/04/25.
//

import SwiftUI

struct SocialSignInView: View {
    var onGoogleSignIn: () -> Void
    
    var body: some View {
        VStack {
            SecondaryButton("Sign in with Google", action: onGoogleSignIn)
            
            HStack(spacing: 20) {
                Rectangle()
                    .foregroundStyle(.secondary.opacity(0.5))
                    .frame(height: 1)
                
                Text("or")
                
                Rectangle()
                    .foregroundStyle(.secondary.opacity(0.5))
                    .frame(height: 1)
            }
            .padding(.top)
        }
    }
}

#Preview {
    SocialSignInView() { }
}
