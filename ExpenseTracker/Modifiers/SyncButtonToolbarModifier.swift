//
//  SyncButtonToolbarModifier.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 18/04/25.
//

import SwiftUI

struct ToolbarSyncButtonModifier: ViewModifier {
    @Environment(UserProvider.self) private var userProvider
    
    @State private var isPresented = false
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isPresented.toggle()
                    } label: {
                        Image(systemName: "person.crop.circle")
                    }
                }
            }
            .sheet(isPresented: $isPresented, content: {
                if let user = userProvider.user {
                    VStack {
                        Text("Hello \(user.email ?? "User")")
                        Button("Sign out") {
                            Task { try? await userProvider.signOut() }
                        }
                    }
                } else {
                    SignInOrSignUpView()
                }
                
            })
    }
}

extension View {
    func toolbarSyncButton() -> some View {
        self.modifier(ToolbarSyncButtonModifier())
    }
}
