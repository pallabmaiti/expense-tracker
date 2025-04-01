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
    /// - Parameters:
    ///   - databaseQuery: The `DatabaseQuery` case representing the database operation to be performed.
    ///   - completion: A closure that returns a `Result` containing either the response data or an error.
    func request(_ databaseQuery: DatabaseQuery, completion: @escaping (Result<Data, Error>) -> Void)
}

/// A concrete implementation of `DatabaseHandler` that interacts with a database through `DatabaseWorker`.
class DatabaseHandlerImpl: DatabaseHandler {
    
    /// A worker responsible for performing database operations.
    let databaseWorker: DatabaseWorker
    
    /// Initializes the `DatabaseHandlerImpl` with an optional database instance.
    /// - Parameter database: The database to be used. Defaults to `UserDefaultsDatabase`.
    init(database: Database = UserDefaultsDatabase()) {
        databaseWorker = DatabaseWorker(datebase: database)
    }
    
    /// Processes a database request based on the provided DatabaseQuery case and returns the result via a completion handler.
    /// - Parameters:
    ///   - databaseQuery: The `DatabaseQuery` case representing the database operation to be performed.
    ///   - completion: A closure returning a `Result` with either `Data` (successful response) or an `Error` (failure).
    func request(_ databaseQuery: DatabaseQuery, completion: @escaping (Result<Data, Error>) -> Void) {
        switch databaseQuery {
        case .getExpenses:
            do {
                let expenses = databaseWorker.fetchExpenseData()
                let jsonData = try JSONSerialization.data(withJSONObject: expenses, options: [])
                completion(.success(jsonData))
            } catch {
                completion(.failure(error))
            }
            
        case let .addExpense(name, amount, date, type, note):
            do {
                let result = try databaseWorker.saveExpense(name: name, amount: amount, date: date, type: type, note: note)
                let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                completion(.success(jsonData))
            } catch {
                completion(.failure(error))
            }
            
        case .deleteExpense(let id):
            do {
                let result = try databaseWorker.deleteExpense(id: id)
                let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                completion(.success(jsonData))
            } catch {
                completion(.failure(error))
            }
            
        case let .updateExpense(id, name, amount, date, type, note):
            do {
                let result = try databaseWorker.updateExpense(id: id, name: name, amount: amount, date: date, type: type, note: note)
                let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                completion(.success(jsonData))
            } catch {
                completion(.failure(error))
            }
            
        case .deleteAllExpenses:
            let result = databaseWorker.deleteAllExpenses()
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                completion(.success(jsonData))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
