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
        
        /// The database manager responsible for performing data operations.
        let databaseManager: DatabaseQueryType
        
        /// Initializes the `ViewModel` with a database manager.
        /// - Parameter databaseManager: The `DatabaseQueryType` that provides database operations (e.g., update, delete).
        init(databaseManager: DatabaseQueryType) {
            self.databaseManager = databaseManager
        }
        
        /// Updates an existing expense in the database.
        /// - Parameters:
        ///   - id: The unique identifier of the expense to update.
        ///   - name: The new name of the expense.
        ///   - amount: The new amount of the expense.
        ///   - date: The new date of the expense in string format.
        ///   - type: The new type of the expense (e.g., Food, Transportation).
        ///   - note: The new note associated with the expense.
        ///   - completion: A closure that returns a `Result` indicating success (`true`) or failure (`false`), along with any error encountered.
        func updateExpense(id: String, name: String, amount: Double, date: String, type: String, note: String, completion: @escaping (Result<Bool, Error>) -> Void) {
            databaseManager.updateExpense(id: id, name: name, amount: amount, date: date, type: type, note: note, completion: completion)
        }
        
        /// Deletes an expense from the database.
        /// - Parameters:
        ///   - id: The unique identifier of the expense to delete.
        ///   - completion: A closure that returns a `Result` indicating success (`true`) or failure (`false`), along with any error encountered.
        func deleteExpense(id: String, completion: @escaping (Result<Bool, Error>) -> Void) {
            databaseManager.deleteExpense(id: id, completion: completion)
        }
    }
}
