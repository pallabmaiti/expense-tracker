//
//  EditIncomeViewModel.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 03/04/25.
//

import Foundation
import Observation

/// `ViewModel` is a class responsible for handling the business logic and interacting with the database manager to update or delete an income.
/// It provides methods to update and delete incomes from the database and returns results via completion handlers.
extension EditIncomeView {
    @Observable
    class ViewModel {
        // MARK: - Public Properties

        /// Boolean flags for displaying error and delete confirmation alerts.
        var showError: Bool = false
        var showDeleteConfirmation: Bool = false
        
        /// State properties for storing the edited income values.
        var amount: Double
        var source: Source
        var date: Date
        
        /// Error message to display in case of an error.
        var errorMessage: String = ""
        
        // MARK: - Private Properties

        /// The income to be edited.
        private let income: Income

        /// The database manager responsible for performing data operations.
        private let databaseManager: DatabaseQueryType
        
        /// Initializes the `ViewModel` with a database manager.
        /// - Parameters:
        ///   - income: The `Income` to be edited.
        ///   - databaseManager: The `DatabaseQueryType` that provides database operations (e.g., update, delete).
        init(income: Income, databaseManager: DatabaseQueryType) {
            self.income = income
            self.databaseManager = databaseManager
            self.amount = income.amount
            self.source = income.source
            self.date = income.formattedDate
        }
        
        // MARK: - Public Methods

        /// Updates an existing income in the database.
        /// - Parameter completion: A closure that returns a `Bool` indicating success (`true`) or failure (`false`).
        func updateIncome(_ completion: @escaping (Bool) -> Void) {
            databaseManager.updateIncome(id: income.id, amount: amount, date: date.formattedString(), source: source.rawValue) { [weak self] result in
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
        
        /// Deletes an income from the database.
        /// - Parameter completion: A closure that returns a `Bool` indicating success (`true`) or failure (`false`).
        func deleteIncome(_ completion: @escaping (Bool) -> Void) {
            databaseManager.deleteIncome(id: income.id) { [weak self] result in
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
