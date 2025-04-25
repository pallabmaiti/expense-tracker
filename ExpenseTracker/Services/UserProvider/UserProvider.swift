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
struct User: Identifiable, Codable, Equatable {
    var id: String
    var email: String?
    var firstName: String?
    var lastName: String?
}

/// A protocol defining the interface for managing user authentication and session state.
///
/// This should be adopted by any type that handles user-related operations like sign-in,
/// sign-up, OTP verification, and sign-out, as well as managing loading states and user info.
///
/// - Note: Marked with `@MainActor` since most operations affect UI-related state.
@MainActor
protocol UserProvider {
    
    /// The currently authenticated user, or `nil` if no user is signed in.
    var user: User? { get }
    
    /// Loads the current user session or initializes any required state.
    ///
    /// - Throws: An error if the user session could not be loaded.
    func load() async throws
    
    /// Initiates a sign-in process with the given email address.
    ///
    /// - Parameter email: The user's email address.
    /// - Throws: A `UserProviderError` if sign-in fails (e.g., invalid email or network error).
    func signIn(email: String) async throws(UserProviderError)
    
    /// Resends the OTP (One-Time Password) to the user’s email.
    ///
    /// - Throws: A `UserProviderError` if resending the OTP fails.
    func resendOTP() async throws(UserProviderError)
    
    /// Verifies the OTP entered by the user.
    ///
    /// - Parameter code: The 6-digit OTP code.
    /// - Throws: A `UserProviderError` if the code is invalid or expired.
    func verifyOTP(_ code: String) async throws(UserProviderError)
    
    /// Initiates Google-based sign-in flow.
    ///
    /// - Throws: A `UserProviderError` if the Google sign-in process fails.
    func signInWithGoogle() async throws(UserProviderError)
    
    /// Signs up a new user with an email address and personal details.
    ///
    /// - Parameters:
    ///   - emailAddress: The user’s email address.
    ///   - firstName: The user’s first name.
    ///   - lastName: The user’s last name.
    /// - Throws: A `UserProviderError` if sign-up fails.
    func signUp(emailAddress: String, firstName: String, lastName: String) async throws(UserProviderError)
    
    /// Signs the user out of the app.
    ///
    /// - Throws: A `UserProviderError` if sign-out fails.
    func signOut() async throws(UserProviderError)
}

/// A class that handles user authentication logic using the Clerk SDK.
/// This class is observable and runs on the main actor, suitable for use in SwiftUI views.
@MainActor
@Observable
class ClerkUserProvider: UserProvider {
    
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
    }
    
    /// Resends the OTP code to the user's email in case it was not received or expired.
    func resendOTP() async throws(UserProviderError) {
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
    }
    
    /// Verifies the OTP code entered by the user during the sign-in process.
    /// - Parameter code: The verification code received in the user's email.
    func verifyOTP(_ code: String) async throws(UserProviderError) {
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
    }
    
    /// Initiates the OAuth-based sign-in flow with Google using Clerk SDK.
    func signInWithGoogle() async throws(UserProviderError) {
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
    }
    
    /// Registers a new user by creating a Clerk sign-up session with provided details.
    /// - Parameters:
    ///   - emailAddress: The user's email address.
    ///   - firstName: The user's first name.
    ///   - lastName: The user's last name.
    func signUp(emailAddress: String, firstName: String, lastName: String) async throws(UserProviderError) {
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
    }
    
    /// Signs out the currently signed-in user and clears their session.
    func signOut() async throws(UserProviderError) {
        do {
            try await clerk.signOut()
        } catch {
            if case let error as ClerkAPIError = error {
                throw UserProviderError.error(error.longMessage ?? error.localizedDescription)
            } else {
                throw UserProviderError.error(error.localizedDescription)
            }
        }
    }
}
