//
//  AddExpenseViewModel.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 28/03/25.
//

import Foundation
import Observation

/// `ViewModel` is an observable class responsible for handling business logic related to adding an expense.
/// It interacts with the `DatabaseManager` (e.g., a database manager) to save the expense data and provides feedback via a completion handler.
/// This class is used within the `AddExpenseView` to manage the state and functionality related to adding an expense.
extension AddExpenseView {
    @Observable
    class ViewModel {
        // MARK: - Public Properties
        
        /// Boolean flags for displaying error and delete confirmation alerts.
        var showError: Bool = false
        
        /// Error message to display in case of an error.
        var errorMessage: String = ""
        
        /// Boolean flags for displaying description of expense category.
        var showInfo: Bool = false
        
        // State properties for handling user input.
        var amount: Double = 0
        var category: Category = .food
        var date: Date = Date()
        var name: String = ""
        var note: String = ""
        
        // MARK: - Private Properties
        
        /// The database manager responsible for handling database operations.
        private let databaseManager: DatabaseManager
        
        /// Initializes the ViewModel with a given `DatabaseManager` (database manager).
        ///
        /// - Parameter databaseManager: An instance of `DatabaseManager` used to interact with the backend or local database.
        init(databaseManager: DatabaseManager) {
            self.databaseManager = databaseManager
        }
        
        // MARK: - Public Methods
        
        /// Adds an expense by calling the `saveExpense` method of the `databaseManager`.
        ///
        /// This method accepts the necessary expense details (name, amount, date, category, and note) and passes them to the database manager to be saved.
        ///
        /// - Returns: A `Bool` indicating success or failure. If successful, it returns `true`; otherwise, `false`.
        func addExpense() async -> Bool {
            do {
                return try await databaseManager.saveExpense(
                    .init(
                        id: UUID().uuidString,
                        name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                        amount: amount,
                        date: date,
                        category: category,
                        note: note.trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                )
            } catch {
                showError = true
                errorMessage = error.localizedDescription
                return false
            }
        }
    }
}
