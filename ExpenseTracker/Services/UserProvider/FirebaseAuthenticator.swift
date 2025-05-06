//
//  FirebaseAuthenticator.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 05/05/25.
//

import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth
import FirebaseCore
import Foundation

enum AuthenticationError: Error {
    /// A generic error case holding a descriptive error message.
    case error(String)
}

extension AuthenticationError: LocalizedError {
    /// Provides a localized error message string for displaying to the user.
    var errorDescription: String? {
        switch self {
        case .error(let message):
            return message
        }
    }
}

/// A protocol defining the necessary authentication actions for managing user sessions.
protocol Authenticator {
    var user: User? { get }
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signOut() throws
    func signInWithGoogle() async throws
}

/// A user model used for session management and user data representation.
struct User: Identifiable, Codable, Equatable {
    var id: String
    var email: String?
    var firstName: String?
    var lastName: String?
}

/// A Firebase-based implementation of the `Authenticator` protocol.
/// Supports email/password and Google authentication.
@Observable
class FirebaseAuthenticator: Authenticator {
    
    /// The currently signed-in user, if any.
    private(set) var user: User?
    
    /// Handle used to observe authentication state changes in Firebase.
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    /// Initializes the authenticator and sets up the auth state listener.
    init() {
        registerAuthStateHandler()
    }
    
    /// Registers a listener for Firebase authentication state changes.
    /// Updates the local `user` property based on Firebase's user session.
    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { _, user in
                if let user {
                    self.user = .init(id: user.uid, email: user.email ?? "")
                } else {
                    self.user = nil
                }
            }
        }
    }
    
    /// Signs in a user using email and password credentials.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    /// - Throws: An error if authentication fails.
    func signIn(email: String, password: String) async throws {
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        user = .init(id: authResult.user.uid, email: authResult.user.email ?? "")
    }
    
    /// Signs in the user using Google OAuth via Firebase.
    ///
    /// - Throws: An error if sign-in fails or if required tokens are missing.
    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthenticationError.error("Missing Firebase client ID.")
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = await windowScene.windows.first,
              let rootViewController = await window.rootViewController else {
            throw AuthenticationError.error("Root view controller not found.")
        }
        
        let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        let user = userAuthentication.user
        
        guard let idToken = user.idToken else {
            throw AuthenticationError.error("ID token missing.")
        }
        
        let accessToken = user.accessToken
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken.tokenString,
            accessToken: accessToken.tokenString
        )
        
        let result = try await Auth.auth().signIn(with: credential)
        let firebaseUser = result.user
        self.user = .init(id: firebaseUser.uid, email: firebaseUser.email ?? "")
    }
    
    /// Creates a new user account with email and password using Firebase Auth.
    ///
    /// - Parameters:
    ///   - email: The email address to register with.
    ///   - password: The password for the new account.
    /// - Throws: An error if the sign-up operation fails.
    func signUp(email: String, password: String) async throws {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        user = .init(id: authResult.user.uid, email: authResult.user.email ?? "")
    }
    
    /// Signs out the currently signed-in user and resets session data.
    ///
    /// - Throws: An error if the sign-out operation fails.
    func signOut() throws {
        try Auth.auth().signOut()
        user = nil
    }
    
    /// Deinitializes the class and removes the authentication state listener.
    deinit {
        if let handler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
}
