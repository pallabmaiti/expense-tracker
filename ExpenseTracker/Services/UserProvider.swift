//
//  UserProvider.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 21/04/25.
//

import Clerk
import Foundation

enum UserProviderError: Error {
    case error(String)
    
    var localizedErrorMessage: String {
        switch self {
        case .error(let message):
            return message
        }
    }
}

struct User: Identifiable, Codable {
    var id: String
    var email: String?
    var firstName: String?
    var lastName: String?
}

@MainActor
@Observable
class UserProvider {
    var isLoading: Bool = false
    
    private var clerk: Clerk = Clerk.shared
    
    init() {
        clerk.configure(publishableKey: Bundle.clerkPublishableKey)
    }
    
    var user: User? {
        if let clerkUser = clerk.user {
            return User(id: clerkUser.id, email: clerkUser.primaryEmailAddress?.emailAddress, firstName: clerkUser.firstName, lastName: clerkUser.lastName)
        }
        return nil
    }
    
    var isLoaded: Bool {
        clerk.isLoaded
    }
    
    func load() async throws {
        try await clerk.load()
    }
    
    func signIn(email: String) async throws(UserProviderError) {
        isLoading = true
        do {
            let signIn = try await SignIn.create(strategy: .identifier(email))
            let emailAddressId = signIn.supportedFirstFactors?.filter({ $0.strategy == "email_code" }).first?.emailAddressId
            try await signIn.prepareFirstFactor(strategy: .emailCode(emailAddressId: emailAddressId))
        } catch {
            if case let error as ClerkAPIError = error {
                throw UserProviderError.error(error.longMessage ?? error.localizedDescription)
            } else {
                throw UserProviderError.error(error.localizedDescription)
            }
        }
        isLoading = false
    }
    
    func resendOTP() async throws(UserProviderError) {
        isLoading = true
        do {
            guard let signIn = clerk.client?.signIn else {
                return
            }
            let emailAddressId = signIn.supportedFirstFactors?.filter({ $0.strategy == "email_code" }).first?.emailAddressId
            try await signIn.prepareFirstFactor(strategy: .emailCode(emailAddressId: emailAddressId))
        } catch {
            if case let error as ClerkAPIError = error {
                throw UserProviderError.error(error.longMessage ?? error.localizedDescription)
            } else {
                throw UserProviderError.error(error.localizedDescription)
            }
        }
        isLoading = false
    }
    
    func verifyOTP(_ code: String) async throws(UserProviderError) {
        isLoading = true
        do {
            guard let signIn = clerk.client?.signIn else {
                return
            }
            try await signIn.attemptFirstFactor(strategy: .emailCode(code: code))
        } catch {
            if case let error as ClerkAPIError = error {
                throw UserProviderError.error(error.longMessage ?? error.localizedDescription)
            } else {
                throw UserProviderError.error(error.localizedDescription)
            }
        }
        isLoading = false
    }
    
    func signInWithGoogle() async throws(UserProviderError) {
        isLoading = true
        do {
            let signIn = try await SignIn.create(strategy: .oauth(provider: .google))
            try await signIn.authenticateWithRedirect()
        } catch {
            if case let error as ClerkAPIError = error {
                throw UserProviderError.error(error.longMessage ?? error.localizedDescription)
            } else {
                throw UserProviderError.error(error.localizedDescription)
            }
        }
        isLoading = false
    }
    
    func signUp(emailAddress: String, firstName: String, lastName: String) async throws(UserProviderError) {
        isLoading = true
        do {
            let signUp = try await SignUp.create(
                strategy: .standard(emailAddress: emailAddress, firstName: firstName, lastName: lastName)
            )
            
            try await signUp.prepareVerification(strategy: .emailCode)
        } catch {
            if case let error as ClerkAPIError = error {
                throw UserProviderError.error(error.longMessage ?? error.localizedDescription)
            } else {
                throw UserProviderError.error(error.localizedDescription)
            }
        }
        isLoading = false
    }
    
    func signOut() async throws(UserProviderError) {
        isLoading = true
        do {
            try await clerk.signOut()
        } catch {
            if case let error as ClerkAPIError = error {
                throw UserProviderError.error(error.message ?? error.localizedDescription)
            } else {
                throw UserProviderError.error(error.localizedDescription)
            }
        }
        isLoading = false
    }
}
