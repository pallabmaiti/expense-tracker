//
//  UserProvider+Environment.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 22/04/25.
//

import SwiftUI

/// An `EnvironmentKey` used to inject a `UserProvider` into the SwiftUI environment.
///
/// This allows access to a shared `UserProvider` instance across views using the `@Environment` property wrapper.
@MainActor
struct UserProviderKey: @preconcurrency EnvironmentKey {
    
    /// The default value for the `UserProvider` environment key.
    ///
    /// This fallback instance is used if no explicit `UserProvider` is injected into the environment.
    static let defaultValue: UserProvider = ClerkUserProvider()
}

extension EnvironmentValues {
    
    /// The `UserProvider` from the SwiftUI environment.
    ///
    /// Use `@Environment(\.userProvider)` in a view to access the shared user provider.
    var userProvider: UserProvider {
        get { self[UserProviderKey.self] }
        set { self[UserProviderKey.self] = newValue }
    }
}
