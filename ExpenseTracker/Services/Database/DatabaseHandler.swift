//
//  DatabaseHandler.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 28/03/25.
//

import Foundation

/// A protocol defining an interface for handling database requests.
protocol DatabaseHandler {
    
    /// Processes a database request based on the provided DatabaseQuery case.
    /// - Parameter databaseQuery: The `DatabaseQuery` case representing the database operation to be performed.
    /// - Returns: The raw `Data` returned from the database operation.
    /// - Throws: An error if the request fails.
    func request(_ databaseQuery: DatabaseQuery) async throws -> Data
}

/// A concrete implementation of `DatabaseHandler` that interacts with a database through `DatabaseWorker`.
final class DatabaseHandlerImpl: DatabaseHandler {
    
    /// A worker responsible for performing database operations.
    private let databaseWorker: DatabaseWorker
    
    /// Initializes the `DatabaseHandlerImpl` with an optional database instance.
    /// - Parameter database: The database to be used. Defaults to `UserDefaultsDatabase`.
    init(database: Database = UserDefaultsDatabase()) {
        databaseWorker = DatabaseWorker(datebase: database)
    }
    
    /// Processes a database request based on the provided DatabaseQuery case and returns the result via a completion handler.
    /// - Parameter databaseQuery: The `DatabaseQuery` case representing the database operation to be performed.
    /// - Returns: The raw `Data` returned from the database operation.
    /// - Throws: An error if the request fails.
    func request(_ databaseQuery: DatabaseQuery) async throws -> Data {
        switch databaseQuery {
        case .getExpenses:
            let expenses = try await databaseWorker.fetchExpenses()
            let jsonData = try JSONSerialization.data(withJSONObject: expenses, options: [])
            return jsonData
            
        case let .addExpense(id, name, amount, date, category, note):
            let result = try await databaseWorker.saveExpense(id: id, name: name, amount: amount, date: date, category: category, note: note)
            let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
            return jsonData
            
        case .deleteExpense(let id):
            let result = try await databaseWorker.deleteExpense(id: id)
            let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
            return jsonData
            
        case let .updateExpense(id, name, amount, date, category, note):
            let result = try await databaseWorker.updateExpense(id: id, name: name, amount: amount, date: date, category: category, note: note)
            let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
            return jsonData
            
        case .deleteAllExpenses:
            let result = try await databaseWorker.deleteAllExpenses()
            let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
            return jsonData
            
        case .getIncomes:
            let expenses = try await databaseWorker.fetchIncomes()
            let jsonData = try JSONSerialization.data(withJSONObject: expenses, options: [])
            return jsonData
            
        case let .addIncome(id, amount, date, source):
            let result = try await databaseWorker.saveIncome(id: id, amount: amount, date: date, source: source)
            let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
            return jsonData
            
        case let .updateIncome(id, amount, date, source):
            let result = try await databaseWorker.updateIncome(id: id, amount: amount, date: date, source: source)
            let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
            return jsonData
            
        case let .deleteIncome(id):
            let result = try await databaseWorker.deleteIncome(id: id)
            let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
            return jsonData
            
        case .deleteAllIncome:
            let result = try await databaseWorker.deleteAllIncomes()
            let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
            return jsonData
        }
    }
}
