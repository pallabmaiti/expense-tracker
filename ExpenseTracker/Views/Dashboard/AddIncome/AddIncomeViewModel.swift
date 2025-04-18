//
//  AddIncomeViewModel.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 03/04/25.
//

import Foundation
import Observation

/// `ViewModel` is an observable class responsible for handling business logic related to adding an income.
/// It interacts with the `DatabaseQueryType` (e.g., a database manager) to save the income data and provides feedback via a completion handler.
/// This class is used within the `AddIncomeView` to manage the state and functionality related to adding an income.
extension AddIncomeView {
    @Observable
    class ViewModel {
        // MARK: - Public Properties

        /// Boolean flags for displaying error and delete confirmation alerts.
        var showError: Bool = false

        /// Error message to display in case of an error.
        var errorMessage: String = ""

        // State properties for handling user input.
        var amount: Double = 0
        var date: Date = Date()
        var source: Source = .salary

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

        /// Adds an income by calling the `saveIncome` method of the `databaseManager`.
        ///
        /// This method accepts the necessary income details (amount, date, and source) and passes them to the database manager to be saved.
        ///
        /// - Parameter completion: A closure that returns a `Bool` indicating success or failure. If successful, it returns `true`; otherwise, `false`.
        func addIncome(_ completion: @escaping (Bool) -> Void) {
            databaseManager.saveIncome(amount: amount, date: date.formattedString(), source: source.rawValue) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let success):
                    completion(success)
                case .failure(let error):
                    completion(false)
                    self.showError = true
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
