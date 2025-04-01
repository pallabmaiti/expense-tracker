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
        
        /// The database manager responsible for handling database operations.
        let databaseManager: DatabaseQueryType
        
        /// Initializes the ViewModel with a given `DatabaseQueryType` (database manager).
        ///
        /// - Parameter databaseManager: An instance of `DatabaseQueryType` used to interact with the backend or local database.
        init(databaseManager: DatabaseQueryType) {
            self.databaseManager = databaseManager
        }
        
        /// Adds an expense by calling the `saveExpense` method of the `databaseManager`.
        ///
        /// This method accepts the necessary expense details (name, amount, date, type, and note) and passes them to the database manager to be saved.
        ///
        /// - Parameters:
        ///   - name: The name of the expense (e.g., "Lunch", "Dinner").
        ///   - amount: The amount spent on the expense.
        ///   - date: The date when the expense occurred, represented as a string.
        ///   - type: The type of the expense (e.g., food, transport).
        ///   - note: Any additional notes about the expense.
        ///   - completion: A closure that returns a `Result` indicating success or failure. If successful, it returns `true`; otherwise, an error message.
        func addExpense(name: String, amount: Double, date: String, type: String, note: String, completion: @escaping (Result<Bool, Error>) -> Void) {
            databaseManager.saveExpense(name: name, amount: amount, date: date, type: type, note: note, completion: completion)
        }
    }
}
