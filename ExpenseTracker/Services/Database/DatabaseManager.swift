//
//  DatabaseManager.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 28/03/25.
//

import Foundation

/// A generic response model for DatabaseQuery responses.
/// - Note: This struct is useful for wrapping DatabaseQuery responses in a consistent format.
/// - Parameter T: A type conforming to `Codable` that represents the response data.
struct Response<T: Codable>: Codable {
    /// The actual response data of type `T`.
    let data: T
}

/// A protocol defining the ExpenseDataStore operations related to managing expenses.
protocol ExpenseDataStore {
    
    /// Fetches all expenses from the database.
    /// - Parameter completion: A closure returning a `Result` with an array of `ExpenseData` on success or an `Error` on failure.
    func fetchExpenses(_ completion: @escaping (Result<[Expense], Error>) -> Void)
    
    /// Saves a new expense to the database.
    /// - Parameters:
    ///   - name: The name or description of the expense.
    ///   - amount: The amount spent.
    ///   - date: The date of the expense in `yyyy-MM-dd` format.
    ///   - category: The category of the expense.
    ///   - note: Additional details about the expense.
    ///   - completion: A closure returning a `Result` with `true` if the expense was saved successfully, or an `Error` if the operation failed.
    func saveExpense(name: String, amount: Double, date: String, category: String, note: String, completion: @escaping (Result<Bool, Error>) -> Void)
    
    /// Deletes an expense from the database.
    /// - Parameters:
    ///   - id: The unique identifier of the expense to delete.
    ///   - completion: A closure returning a `Result` with `true` if the expense was deleted successfully, or an `Error` if the operation failed.
    func deleteExpense(id: String, completion: @escaping (Result<Bool, Error>) -> Void)
    
    /// Updates an existing expense in the database.
    /// - Parameters:
    ///   - id: The unique identifier of the expense to update.
    ///   - name: The updated name or description of the expense.
    ///   - amount: The updated amount spent.
    ///   - date: The updated date of the expense in `yyyy-MM-dd` format.
    ///   - category: The updated category of the expense.
    ///   - note: The updated details about the expense.
    ///   - completion: A closure returning a `Result` with `true` if the update was successful, or an `Error` if the operation failed.
    func updateExpense(id: String, name: String, amount: Double, date: String, category: String, note: String, completion: @escaping (Result<Bool, Error>) -> Void)
    
    /// Deletes all stored expenses from the database.
    /// - Parameter completion: A closure returning a `Result` with `true` if all expenses were deleted successfully, or an `Error` if the operation failed.
    func deleteAllExpenses(completion: @escaping (Result<Bool, Error>) -> Void)
}

/// A protocol defining the IncomeDataStore operations related to managing incomes.
protocol IncomeDataStore {
    /// Fetches all income records from the database.
    /// - Parameter completion: A closure that returns a `Result` containing either an array of `Income` objects or an `Error`.
    func fetchIncomes(_ completion: @escaping (Result<[Income], Error>) -> Void)
    
    /// Saves a new income entry to the database.
    /// - Parameters:
    ///   - amount: The amount of income.
    ///   - date: The date of the income entry in string format.
    ///   - source: The source of income as a string.
    ///   - completion: A closure that returns a `Result` indicating success (`true`) or failure (`Error`).
    func saveIncome(amount: Double, date: String, source: String, completion: @escaping (Result<Bool, Error>) -> Void)
    
    /// Deletes a specific income entry from the database.
    /// - Parameters:
    ///   - id: The unique identifier of the income entry to delete.
    ///   - completion: A closure that returns a `Result` indicating success (`true`) or failure (`Error`).
    func deleteIncome(id: String, completion: @escaping (Result<Bool, Error>) -> Void)
    
    /// Updates an existing income entry in the database.
    /// - Parameters:
    ///   - id: The unique identifier of the income entry to update.
    ///   - amount: The new amount of income.
    ///   - date: The updated date of the income entry in string format.
    ///   - source: The updated source of income as a string.
    ///   - completion: A closure that returns a `Result` indicating success (`true`) or failure (`Error`).
    func updateIncome(id: String, amount: Double, date: String, source: String, completion: @escaping (Result<Bool, Error>) -> Void)
    
    /// Deletes all income records from the database.
    /// - Parameter completion: A closure that returns a `Result` indicating success (`true`) or failure (`Error`).
    func deleteAllIncome(completion: @escaping (Result<Bool, Error>) -> Void)
}

typealias DatabaseQueryType = ExpenseDataStore & IncomeDataStore

/// A class that manages expense-related operations by interacting with a `DatabaseHandler`.
class DatabaseManager: ExpenseDataStore, IncomeDataStore {
    
    /// A reference to the `DatabaseHandler` that processes database requests.
    let databaseHandler: DatabaseHandler
    
    /// Initializes the `DatabaseManager` with a `DatabaseHandler`.
    /// - Parameter databaseHandler: The handler responsible for executing database operations.
    init(databaseHandler: DatabaseHandler) {
        self.databaseHandler = databaseHandler
    }
    
    /// Fetches all expenses from the database and decodes the response.
    /// - Parameter completion: A closure returning a `Result` with an array of `Expense` on success or an `Error` on failure.
    func fetchExpenses(_ completion: @escaping (Result<[Expense], Error>) -> Void) {
        databaseHandler.request(.getExpenses) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    
    /// Saves a new expense in the database.
    /// - SeeAlso: `ExpenseDataStore.saveExpense(name:amount:date:category:note:completion:)`
    func saveExpense(name: String, amount: Double, date: String, category: String, note: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        databaseHandler.request(.addExpense(name, amount, date, category, note)) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    
    /// Deletes an expense from the database.
    /// - SeeAlso: `ExpenseDataStore.deleteExpense(id:completion:)`
    func deleteExpense(id: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        databaseHandler.request(.deleteExpense(id)) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    
    /// Updates an existing expense in the database.
    /// - SeeAlso: `ExpenseDataStore.updateExpense(id:name:amount:date:category:note:completion:)`
    func updateExpense(id: String, name: String, amount: Double, date: String, category: String, note: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        databaseHandler.request(.updateExpense(id, name, amount, date, category, note)) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    
    /// Deletes all expenses from the database.
    /// - SeeAlso: `ExpenseDataStore.deleteAllExpenses(completion:)`
    func deleteAllExpenses(completion: @escaping (Result<Bool, Error>) -> Void) {
        databaseHandler.request(.deleteAllExpenses) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    
    /// Fetches all incomes from the database.
    /// - Parameter completion: A closure returning a `Result` with an array of `Income` on success or an `Error` on failure.
    func fetchIncomes(_ completion: @escaping (Result<[Income], Error>) -> Void) {
        databaseHandler.request(.getIncomes) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    
    /// Saves a new income entry.
    /// - SeeAlso: `IncomeDataStore.saveIncome(amount:date:source:completion:)`
    func saveIncome(amount: Double, date: String, source: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        databaseHandler.request(.addIncome(amount, date, source)) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    
    /// Updates an existing income entry.
    /// - SeeAlso: `IncomeDataStore.updateIncome(id:amount:date:source:completion:)`
    func updateIncome(id: String, amount: Double, date: String, source: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        databaseHandler.request(.updateIncome(id, amount, date, source)) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    
    /// Deletes a specific income entry.
    /// - SeeAlso: `IncomeDataStore.deleteIncome(id:completion:)`
    func deleteIncome(id: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        databaseHandler.request(.deleteIncome(id)) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    
    /// Deletes all income entries from the database.
    /// - SeeAlso: `IncomeDataStore.deleteAllIncome(completion:)`
    func deleteAllIncome(completion: @escaping (Result<Bool, Error>) -> Void) {
        databaseHandler.request(.deleteAllIncome) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    
    /// Generic method to handle response decoding.
    private func handleResponse<T: Codable>(_ result: Result<Data, Error>, completion: @escaping (Result<T, Error>) -> Void) {
        switch result {
        case .success(let data):
            do {
                let response = try JSONDecoder().decode(Response<T>.self, from: data)
                completion(.success(response.data))
            } catch {
                completion(.failure(error))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
