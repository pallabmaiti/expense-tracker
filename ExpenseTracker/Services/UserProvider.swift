//
//  UserProvider.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 21/04/25.
//

import Clerk
import Foundation

/// Represents possible errors that can occur during user authentication or interaction.
enum UserProviderError: Error {
    /// A generic error case holding a descriptive error message.
    case error(String)
    
    /// Provides a localized error message string for displaying to the user.
    var localizedErrorMessage: String {
        switch self {
        case .error(let message):
            return message
        }
    }
}

/// Represents a user model conforming to `Identifiable` and `Codable` protocols.
/// Used for storing and presenting user-related information in the app.
struct User: Identifiable, Codable {
    var id: String
    var email: String?
    var firstName: String?
    var lastName: String?
}

/// A class that handles user authentication logic using the Clerk SDK.
/// This class is observable and runs on the main actor, suitable for use in SwiftUI views.
@MainActor
@Observable
class UserProvider {
    
    /// A flag indicating whether an authentication operation is currently in progress.
    var isLoading: Bool = false
    
    /// Reference to the shared Clerk instance used for all authentication operations.
    private var clerk: Clerk = Clerk.shared
    
    /// Initializes the `UserProvider` and configures the Clerk SDK with the publishable key.
    init() {
        clerk.configure(publishableKey: Bundle.clerkPublishableKey)
    }
    
    /// Computed property that returns the currently signed-in user, if available.
    /// Converts the `Clerk.User` to the app’s internal `User` model.
    var user: User? {
        if let clerkUser = clerk.user {
            return User(
                id: clerkUser.id,
                email: clerkUser.primaryEmailAddress?.emailAddress,
                firstName: clerkUser.firstName,
                lastName: clerkUser.lastName
            )
        }
        return nil
    }
    
    /// Indicates whether Clerk has completed loading user session and authentication state.
    var isLoaded: Bool {
        clerk.isLoaded
    }
    
    /// Loads the Clerk SDK and prepares it to provide user session data.
    func load() async throws {
        try await clerk.load()
    }
    
    /// Starts the email-based sign-in flow using the Clerk SDK.
    /// - Parameter email: The email address the user provides for authentication.
    func signIn(email: String) async throws(UserProviderError) {
        isLoading = true
        do {
            // Initiate a sign-in attempt with email strategy.
            let signIn = try await SignIn.create(strategy: .identifier(email))
            
            // Extract the email address ID needed to trigger the email verification code.
            let emailAddressId = signIn.supportedFirstFactors?.first(where: { $0.strategy == "email_code" })?.emailAddressId
            
            // Prepare the first factor of authentication using the email code.
            try await signIn.prepareFirstFactor(strategy: .emailCode(emailAddressId: emailAddressId))
        } catch {
            // Map Clerk-specific or generic errors into the app-specific error type.
            if case let error as ClerkAPIError = error {
                throw UserProviderError.error(error.longMessage ?? error.localizedDescription)
            } else {
                throw UserProviderError.error(error.localizedDescription)
            }
        }
        isLoading = false
    }
    
    /// Resends the OTP code to the user's email in case it was not received or expired.
    func resendOTP() async throws(UserProviderError) {
        isLoading = true
        do {
            // Ensure that the sign-in session exists.
            guard let signIn = clerk.client?.signIn else { return }
            
            // Extract email address ID and re-trigger the OTP.
            let emailAddressId = signIn.supportedFirstFactors?.first(where: { $0.strategy == "email_code" })?.emailAddressId
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
    
    /// Verifies the OTP code entered by the user during the sign-in process.
    /// - Parameter code: The verification code received in the user's email.
    func verifyOTP(_ code: String) async throws(UserProviderError) {
        isLoading = true
        do {
            guard let signIn = clerk.client?.signIn else { return }
            
            // Attempt to verify the code entered by the user.
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
    
    /// Initiates the OAuth-based sign-in flow with Google using Clerk SDK.
    func signInWithGoogle() async throws(UserProviderError) {
        isLoading = true
        do {
            let signIn = try await SignIn.create(strategy: .oauth(provider: .google))
            
            // This will redirect the user to Google’s authentication page.
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
    
    /// Registers a new user by creating a Clerk sign-up session with provided details.
    /// - Parameters:
    ///   - emailAddress: The user's email address.
    ///   - firstName: The user's first name.
    ///   - lastName: The user's last name.
    func signUp(emailAddress: String, firstName: String, lastName: String) async throws(UserProviderError) {
        isLoading = true
        do {
            // Create a sign-up request with basic info and email strategy.
            let signUp = try await SignUp.create(
                strategy: .standard(
                    emailAddress: emailAddress,
                    firstName: firstName,
                    lastName: lastName
                )
            )
            
            // Trigger email verification by sending a code.
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
    
    /// Signs out the currently signed-in user and clears their session.
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
