//
//  AddExpenseViewModel.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 28/03/25.
//

import Foundation
import Observation

/// `ViewModel` is an observable class responsible for handling business logic related to adding an expense.
/// It interacts with the `DatabaseQueryType` (e.g., a database manager) to save the expense data and provides feedback via a completion handler.
/// This class is used within the `AddExpenseView` to manage the state and functionality related to adding an expense.
extension AddExpenseView {
    @Observable
    class ViewModel {
        // MARK: - Public Properties

        /// Boolean flags for displaying error and delete confirmation alerts.
        var showError: Bool = false

        /// Error message to display in case of an error.
        var errorMessage: String = ""

        // State properties for handling user input.
        var amount: Double = 0
        var category: Category = .food
        var date: Date = Date()
        var name: String = ""
        var note: String = ""

        // MARK: - Private Properties

        /// The database manager responsible for handling database operations.
        private let databaseManager: DatabaseQueryType
        
        /// Initializes the ViewModel with a given `DatabaseQueryType` (database manager).
        ///
        /// - Parameter databaseManager: An instance of `DatabaseQueryType` used to interact with the backend or local database.
        init(databaseManager: DatabaseQueryType) {
            self.databaseManager = databaseManager
        }
        
        // MARK: - Public Methods

        /// Adds an expense by calling the `saveExpense` method of the `databaseManager`.
        ///
        /// This method accepts the necessary expense details (name, amount, date, category, and note) and passes them to the database manager to be saved.
        ///
        /// - Parameter completion: A closure that returns a `Bool` indicating success or failure. If successful, it returns `true`; otherwise, `false`.
        func addExpense(_ completion: @escaping (Bool) -> Void) {
            databaseManager.saveExpense(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                amount: amount,
                date: date.formattedString(),
                category: category.rawValue,
                note: note.trimmingCharacters(in: .whitespacesAndNewlines)
            ) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let success):
                    completion(success)
                case .failure(let error):
                    completion(false)
                    showError = true
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
