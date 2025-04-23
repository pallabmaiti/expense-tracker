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
    /// - Returns: An `Array` containing `Expense` objects
    /// - Throws: An `Error` if the operation failed.
    func fetchExpenses() async throws -> [Expense]
    
    /// Saves a new expense to the database.
    /// - Parameters:
    ///   - name: The name or description of the expense.
    ///   - amount: The amount spent.
    ///   - date: The date of the expense in `yyyy-MM-dd` format.
    ///   - category: The category of the expense.
    ///   - note: Additional details about the expense.
    /// - Returns: A `Bool` with `true` if the expense was saved successfully.
    /// - Throws: An `Error` if the operation failed.
    func saveExpense(name: String, amount: Double, date: String, category: String, note: String) async throws -> Bool
    
    /// Deletes an expense from the database.
    /// - Parameters:
    ///   - id: The unique identifier of the expense to delete.
    /// - Returns: A `Bool` with `true` if the expense was deleted successfully.
    /// - Throws: An `Error` if the operation failed.
    func deleteExpense(id: String) async throws -> Bool
    
    /// Updates an existing expense in the database.
    /// - Parameters:
    ///   - id: The unique identifier of the expense to update.
    ///   - name: The updated name or description of the expense.
    ///   - amount: The updated amount spent.
    ///   - date: The updated date of the expense in `yyyy-MM-dd` format.
    ///   - category: The updated category of the expense.
    ///   - note: The updated details about the expense.
    /// - Returns: A `Bool` with `true` if the update was successful.
    /// - Throws: An `Error` if the operation failed.
    func updateExpense(id: String, name: String, amount: Double, date: String, category: String, note: String) async throws -> Bool
    
    /// Deletes all stored expenses from the database.
    /// - Returns: A `Bool` with `true` if all expenses were deleted successfully
    /// - Throws: An `Error` if the operation failed.
    func deleteAllExpenses() async throws -> Bool
}

/// A protocol defining the IncomeDataStore operations related to managing incomes.
protocol IncomeDataStore {
    /// Fetches all income records from the database.
    /// - Returns: An `Array` containing `Income` objects
    /// - Throws: An `Error` if the operation failed.
    func fetchIncomes() async throws -> [Income]
    
    /// Saves a new income entry to the database.
    /// - Parameters:
    ///   - amount: The amount of income.
    ///   - date: The date of the income entry in string format.
    ///   - source: The source of income as a string.
    /// - Returns: A `Bool` with `true` if the income was saved successfully.
    /// - Throws: An `Error` if the operation failed.
    func saveIncome(amount: Double, date: String, source: String) async throws -> Bool
    
    /// Deletes a specific income entry from the database.
    /// - Parameter id: The unique identifier of the income entry to delete.
    /// - Returns: A `Bool` with `true` if the income was deleted successfully.
    /// - Throws: An `Error` if the operation failed.
    func deleteIncome(id: String) async throws -> Bool
    
    /// Updates an existing income entry in the database.
    /// - Parameters:
    ///   - id: The unique identifier of the income entry to update.
    ///   - amount: The new amount of income.
    ///   - date: The updated date of the income entry in string format.
    ///   - source: The updated source of income as a string.
    /// - Returns: A `Bool` with `true` if the update was successful.
    /// - Throws: An `Error` if the operation failed.
    func updateIncome(id: String, amount: Double, date: String, source: String) async throws -> Bool
    
    /// Deletes all income records from the database.
    /// - Returns: A `Bool` with `true` if all incomes were deleted successfully
    /// - Throws: An `Error` if the operation failed.
    func deleteAllIncomes() async throws -> Bool
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
    /// - SeeAlso: `ExpenseDataStore.fetchExpenses()`
    func fetchExpenses() async throws -> [Expense] {
        let data = try await databaseHandler.request(.getExpenses)
        return try handleResponse(data)
    }
    
    /// Saves a new expense in the database.
    /// - SeeAlso: `ExpenseDataStore.saveExpense(name:amount:date:category:note:)`
    func saveExpense(name: String, amount: Double, date: String, category: String, note: String) async throws -> Bool {
        let data = try await databaseHandler.request(.addExpense(name, amount, date, category, note))
        return try handleResponse(data)
    }
    
    /// Deletes an expense from the database.
    /// - SeeAlso: `ExpenseDataStore.deleteExpense(id:)`
    func deleteExpense(id: String) async throws -> Bool {
        let data = try await databaseHandler.request(.deleteExpense(id))
        return try handleResponse(data)
    }
    
    /// Updates an existing expense in the database.
    /// - SeeAlso: `ExpenseDataStore.updateExpense(id:name:amount:date:category:note:)`
    func updateExpense(id: String, name: String, amount: Double, date: String, category: String, note: String) async throws -> Bool {
        let data = try await databaseHandler.request(.updateExpense(id, name, amount, date, category, note))
        return try handleResponse(data)
    }
    
    /// Deletes all expenses from the database.
    /// - SeeAlso: `ExpenseDataStore.deleteAllExpenses()`
    func deleteAllExpenses() async throws -> Bool {
        let data = try await databaseHandler.request(.deleteAllExpenses)
        return try handleResponse(data)
    }
    
    /// Fetches all incomes from the database.
    /// - SeeAlso: `IncomeDataStore.fetchIncomes()`
    func fetchIncomes() async throws -> [Income] {
        let data = try await databaseHandler.request(.getIncomes)
        return try handleResponse(data)
    }
    
    /// Saves a new income entry.
    /// - SeeAlso: `IncomeDataStore.saveIncome(amount:date:source:)`
    func saveIncome(amount: Double, date: String, source: String) async throws -> Bool {
        let data = try await databaseHandler.request(.addIncome(amount, date, source))
        return try handleResponse(data)
    }
    
    /// Updates an existing income entry.
    /// - SeeAlso: `IncomeDataStore.updateIncome(id:amount:date:source:)`
    func updateIncome(id: String, amount: Double, date: String, source: String) async throws -> Bool {
        let data = try await databaseHandler.request(.updateIncome(id, amount, date, source))
        return try handleResponse(data)
    }
    
    /// Deletes a specific income entry.
    /// - SeeAlso: `IncomeDataStore.deleteIncome(id:)`
    func deleteIncome(id: String) async throws -> Bool {
        let data = try await databaseHandler.request(.deleteIncome(id))
        return try handleResponse(data)
    }
    
    /// Deletes all income entries from the database.
    /// - SeeAlso: `IncomeDataStore.deleteAllIncome()`
    func deleteAllIncomes() async throws -> Bool {
        let data = try await databaseHandler.request(.deleteAllIncome)
        return try handleResponse(data)
    }
    
    /// Generic method to handle response decoding.
    private func handleResponse<T: Codable>(_ data: Data) throws -> T {
        let response = try JSONDecoder().decode(Response<T>.self, from: data)
        return response.data
    }
}
