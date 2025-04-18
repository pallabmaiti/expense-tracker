//
//  EditExpenseViewModel.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 28/03/25.
//

import Foundation
import Observation

/// `ViewModel` is a class responsible for handling the business logic and interacting with the database manager to update or delete an expense.
/// It provides methods to update and delete expenses from the database and returns results via completion handlers.
extension EditExpenseView {
    @Observable
    class ViewModel {
        // MARK: - Public Properties

        /// Boolean flags for displaying error and delete confirmation alerts.
        var showError: Bool = false
        var showDeleteConfirmation: Bool = false
        
        /// State properties for storing the edited expense values.
        var amount: Double
        var category: Category
        var date: Date
        var name: String
        var note: String
        
        /// Error message to display in case of an error.
        var errorMessage: String = ""

        // MARK: - Private Properties

        /// The database manager responsible for performing data operations.
        private let databaseManager: DatabaseQueryType
        
        /// The expense to be edited.
        private let expense: Expense

        /// Initializes the `ViewModel` with a database manager.
        /// - Parameters:
        ///   - expense: The `Expense` to be edited.
        ///   - databaseManager: The `DatabaseQueryType` that provides database operations (e.g., update, delete).
        init(expense: Expense, databaseManager: DatabaseQueryType) {
            self.databaseManager = databaseManager
            self.expense = expense
            self.amount = expense.amount
            self.category = expense.category
            self.date = expense.formattedDate
            self.name = expense.name
            self.note = expense.note
        }
        
        // MARK: - Public Methods

        /// Updates an existing expense in the database.
        /// - Parameter completion: A closure that returns a `Bool` indicating success (`true`) or failure (`false`).
        func updateExpense(_ completion: @escaping (Bool) -> Void) {
            databaseManager.updateExpense(
                id: expense.id,
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                amount: amount,
                date: date.formattedString(),
                category: category.rawValue,
                note: note.trimmingCharacters(in: .whitespacesAndNewlines)
            ) { [weak self] result in
                guard let self else { return }
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
        
        /// Deletes an expense from the database.
        /// - Parameter completion: A closure that returns a `Bool` indicating success (`true`) or failure (`false`).
        func deleteExpense(_ completion: @escaping (Bool) -> Void) {
            databaseManager.deleteExpense(id: expense.id) { [weak self] result in
                guard let self else { return }
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
