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
    
    /// The `TabManager` is injected from the environment and used to track the currently selected tab index.
    @EnvironmentObject var tabManager: TabManager
    
    /// The `databaseManager` handles all interactions with the data layer, such as reading from or writing to the local database.
    ///
    /// It's initialized with a default implementation using `DatabaseManager` and `DatabaseHandlerImpl`,
    /// but can be injected with a custom instance for testing or previewing.
    private let databaseManager: DatabaseQueryType
    
    /// Initializes the `ContentView` with a `databaseManager`.
    ///
    /// - Parameter databaseManager: The object that conforms to `DatabaseQueryType` for managing database operations.
    init(databaseManager: DatabaseQueryType = DatabaseManager(databaseHandler: DatabaseHandlerImpl())) {
        self.databaseManager = databaseManager
    }
    
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
    }
}

#Preview {
    ContentView(databaseManager: DatabaseManager(databaseHandler: DatabaseHandlerImpl(database: InMemoryDatabase())))
        .environmentObject(TabManager())
}
