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

/// A protocol defining the DatabaseQuery operations related to managing expenses.
protocol DatabaseQueryType {
    
    /// Fetches all expenses from the database.
    /// - Parameter completion: A closure returning a `Result` with an array of `ExpenseData` on success or an `Error` on failure.
    func fetchExpenses(_ completion: @escaping (Result<[ExpenseData], Error>) -> Void)
    
    /// Saves a new expense to the database.
    /// - Parameters:
    ///   - name: The name or description of the expense.
    ///   - amount: The amount spent.
    ///   - date: The date of the expense in `yyyy-MM-dd` format.
    ///   - type: The category or type of the expense.
    ///   - note: Additional details about the expense.
    ///   - completion: A closure returning a `Result` with `true` if the expense was saved successfully, or an `Error` if the operation failed.
    func saveExpense(name: String, amount: Double, date: String, type: String, note: String, completion: @escaping (Result<Bool, Error>) -> Void)
    
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
    ///   - type: The updated category or type of the expense.
    ///   - note: The updated details about the expense.
    ///   - completion: A closure returning a `Result` with `true` if the update was successful, or an `Error` if the operation failed.
    func updateExpense(id: String, name: String, amount: Double, date: String, type: String, note: String, completion: @escaping (Result<Bool, Error>) -> Void)
    
    /// Deletes all stored expenses from the database.
    /// - Parameter completion: A closure returning a `Result` with `true` if all expenses were deleted successfully, or an `Error` if the operation failed.
    func deleteAllExpenses(completion: @escaping (Result<Bool, Error>) -> Void)
}

/// A class that manages expense-related operations by interacting with a `DatabaseHandler`.
class DatabaseManager: DatabaseQueryType {
    
    /// A reference to the `DatabaseHandler` that processes database requests.
    let databaseHandler: DatabaseHandler
    
    /// Initializes the `DatabaseManager` with a `DatabaseHandler`.
    /// - Parameter databaseHandler: The handler responsible for executing database operations.
    init(databaseHandler: DatabaseHandler) {
        self.databaseHandler = databaseHandler
    }
    
    /// Fetches all expenses from the database and decodes the response.
    /// - Parameter completion: A closure returning a `Result` with an array of `ExpenseData` on success or an `Error` on failure.
    func fetchExpenses(_ completion: @escaping (Result<[ExpenseData], Error>) -> Void) {
        databaseHandler.request(.getExpenses) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(Response<[ExpenseData]>.self, from: data)
                    completion(.success(response.data))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Saves a new expense in the database.
    /// - SeeAlso: `DatabaseQueryType.saveExpense(name:amount:date:type:note:completion:)`
    func saveExpense(name: String, amount: Double, date: String, type: String, note: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        databaseHandler.request(.addExpense(name, amount, date, type, note)) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(Response<Bool>.self, from: data)
                    completion(.success(response.data))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Deletes an expense from the database.
    /// - SeeAlso: `DatabaseQueryType.deleteExpense(id:completion:)`
    func deleteExpense(id: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        databaseHandler.request(.deleteExpense(id)) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(Response<Bool>.self, from: data)
                    completion(.success(response.data))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Updates an existing expense in the database.
    /// - SeeAlso: `DatabaseQueryType.updateExpense(id:name:amount:date:type:note:completion:)`
    func updateExpense(id: String, name: String, amount: Double, date: String, type: String, note: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        databaseHandler.request(.updateExpense(id, name, amount, date, type, note)) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(Response<Bool>.self, from: data)
                    completion(.success(response.data))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Deletes all expenses from the database.
    /// - SeeAlso: `DatabaseQueryType.deleteAllExpenses(completion:)`
    func deleteAllExpenses(completion: @escaping (Result<Bool, Error>) -> Void) {
        databaseHandler.request(.deleteAllExpenses) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(Response<Bool>.self, from: data)
                    completion(.success(response.data))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
