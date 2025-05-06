//
//  AccountView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 06/05/25.
//

import SwiftUI

struct AccountView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var viewModel: ViewModel
    
    init(authenticator: Authenticator, databaseManager: DatabaseManager) {
        _viewModel = State(initialValue: .init(authenticator: authenticator, databaseManager: databaseManager))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    Button {
                        
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 100, height: 100)
                    }
                    
                    Text(viewModel.email)
                }
                .padding()
                
                
                Form {
                    HStack {
                        Text("First Name")
                        Spacer()
                        TextField("Jon", text: $viewModel.firstName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Last Name")
                        Spacer()
                        TextField("Doe", text: $viewModel.lastName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Section {
                        NavigationLink(destination: Text("Settings")) {
                            VStack(alignment: .leading) {
                                Text("Email")
                                Text(viewModel.email)
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                        }
                        
                        NavigationLink(destination: Text("Settings")) {
                            VStack(alignment: .leading) {
                                Text("Password")
                                Text("********")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                    
                    Button {
                        viewModel.signOut()
                        dismiss()
                    } label: {
                        Text("Sign Out")
                            .frame(maxWidth: .infinity)
                    }
                    .tint(.red1)
                }
                
                
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

#Preview {
    AccountView(authenticator: FirebaseAuthenticator(), databaseManager: .inMemoryDatabaseManager)
}
