//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 02/04/25.
//

import SwiftUI

/// The main content view that hosts the tab-based navigation for the app.
///
/// This view displays the `DashboardView`, `TransactionsView`, and `InsightsView`
/// as separate tabs, allowing users to switch between core sections of the app.
struct ContentView: View {
    /// The environment-injected instance of `DatabaseManager`.
    ///
    /// This is used to interact with the current database implementation,
    /// which may be local, in-memory, or Firebase-based depending on the selected `DatabaseType`.
    @Environment(DatabaseManager.self) var databaseManager
    
    /// The `TabManager` is injected from the environment and used to track the currently selected tab index.
    @EnvironmentObject var tabManager: TabManager
    
    @State private var isLoading = false
    
    /// The body of the `ContentView`, which defines a `TabView` to display multiple sections of the app.
    ///
    /// The `selection` binding to `tabManager.selectedTabIndex` allows dynamic switching between tabs programmatically.
    var body: some View {
        TabView(selection: $tabManager.selectedTabIndex) {
            
            /// The Dashboard tab shows a high-level overview of finances.
            DashboardView(databaseManager: databaseManager)
                .tabItem {
                    Image(systemName: "house")
                    Text("Dashboard")
                }
                .tag(0)
            
            /// The Transactions tab displays all income and expense records.
            TransactionsView(databaseManager: databaseManager)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Transactions")
                }
                .tag(1)
            
            /// The Insights tab visualizes income and expense breakdowns using charts.
            InsightsView(databaseManager: databaseManager)
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Insights")
                }
                .tag(2)
        }
        //.tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview {
    ContentView()
        .environmentObject(TabManager())
        .environment(DatabaseManager.initWithInMemory)
        .environment(\.authenticator, FirebaseAuthenticator())
        .environment(NotificationManager(center: .init(), settings: NotificationSettingsHandler()))
}
