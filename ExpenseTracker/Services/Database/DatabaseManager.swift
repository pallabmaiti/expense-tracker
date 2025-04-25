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

/// A central manager responsible for coordinating database operations.
///
/// The `DatabaseManager` maintains references to a local and (optionally) remote `DatabaseHandler`.
/// It delegates all database operations to these handlers as needed.
@Observable
class DatabaseManager {
    
    // MARK: - Properties
    
    /// A reference to the `DatabaseHandler` that processes local database requests.
    ///
    /// Typically initialized during app startup and used for persistent on-device storage
    private let localDatabaseHandler: DatabaseHandler
    
    /// An optional reference to a remote `DatabaseHandler`, such as Firebase.
    ///
    /// This is used when syncing or storing user data in the cloud. It can be dynamically
    /// initialized or deinitialized based on authentication state.
    private var remoteDatabaseHandler: DatabaseHandler?
    
    // MARK: - Initialization
    
    /// Initializes the `DatabaseManager` with a `DatabaseHandler`.
    ///
    /// - Parameter databaseHandler: The handler responsible for executing local database operations.
    init(databaseHandler: DatabaseHandler) {
        self.localDatabaseHandler = databaseHandler
    }
        
    /// Assigns a `DatabaseHandler` to be used as the remote handler.
    ///
    /// This is typically called after user authentication to enable cloud data syncing.
    ///
    /// - Parameter databaseHandler: The remote database handler (e.g., Firebase).
    func initializeRemoteDatabaseHandler(_ databaseHandler: DatabaseHandler) {
        self.remoteDatabaseHandler = databaseHandler
    }
    
    /// Clears the reference to the remote `DatabaseHandler`.
    ///
    /// This is typically called during sign-out to stop cloud-based operations.
    func deinitializeRemoteDatabaseHandler() {
        self.remoteDatabaseHandler = nil
    }

    /// Fetches all expenses from the database.
    /// - Returns: An `Array` containing `Expense` objects
    /// - Throws: An `Error` if the operation failed.
    func fetchExpenses() async throws -> [Expense] {
        let (localResult, remoteResult) = try await (localDatabaseHandler.request(.getExpenses), remoteDatabaseHandler?.request(.getExpenses))
        
        let localExpenses: [Expense] = try handleResponse(localResult)
        if let remoteResult {
            let remoteExpenses: [Expense] = try handleResponse(remoteResult)
            await syncRemoteWithLocal(localExpenses: localExpenses, remoteExpenses: remoteExpenses)
        }
        
        return localExpenses
    }
    
    /// Saves a new expense to the database.
    /// - Parameters:
    ///   - id: The unique identifier of the expense.
    ///   - name: The name or description of the expense.
    ///   - amount: The amount spent.
    ///   - date: The date of the expense in `yyyy-MM-dd` format.
    ///   - category: The category of the expense.
    ///   - note: Additional details about the expense.
    /// - Returns: A `Bool` with `true` if the expense was saved successfully.
    /// - Throws: An `Error` if the operation failed.
    func saveExpense(id: String, name: String, amount: Double, date: String, category: String, note: String) async throws -> Bool {
        async let localExpensesData = localDatabaseHandler.request(.addExpense(id, name, amount, date, category, note))
        async let remoteExpensesData = remoteDatabaseHandler?.request(.addExpense(id, name, amount, date, category, note))
        
        let (localResult, _) = try await (localExpensesData, remoteExpensesData)
        
        return try handleResponse(localResult)
    }
    
    /// Deletes an expense from the database.
    /// - Parameters:
    ///   - id: The unique identifier of the expense to delete.
    /// - Returns: A `Bool` with `true` if the expense was deleted successfully.
    /// - Throws: An `Error` if the operation failed.
    func deleteExpense(id: String) async throws -> Bool {
        let (localResult, _) = try await (localDatabaseHandler.request(.deleteExpense(id)), remoteDatabaseHandler?.request(.deleteExpense(id)))
        return try handleResponse(localResult)
    }
    
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
    func updateExpense(id: String, name: String, amount: Double, date: String, category: String, note: String) async throws -> Bool {
        let (localResult, _) = try await (localDatabaseHandler.request(.updateExpense(id, name, amount, date, category, note)), remoteDatabaseHandler?.request(.updateExpense(id, name, amount, date, category, note)))
        return try handleResponse(localResult)
    }
    
    /// Deletes all stored expenses from the database.
    /// - Returns: A `Bool` with `true` if all expenses were deleted successfully.
    /// - Throws: An `Error` if the operation failed.
    func deleteAllExpenses() async throws -> Bool {
        let (localResult, _) = try await (localDatabaseHandler.request(.deleteAllExpenses), remoteDatabaseHandler?.request(.deleteAllExpenses))
        return try handleResponse(localResult)
    }
    
    /// Fetches all income records from the database.
    /// - Returns: An `Array` containing `Income` objects
    /// - Throws: An `Error` if the operation failed.
    func fetchIncomes() async throws -> [Income] {
        let (localResult, remoteResult) = try await (localDatabaseHandler.request(.getIncomes), remoteDatabaseHandler?.request(.getIncomes))
        let localIncomes: [Income] = try handleResponse(localResult)
        if let remoteResult {
            let remoteIncomes: [Income] = try handleResponse(remoteResult)
            await syncRemoteWithLocal(localIncomes: localIncomes, remoteIncomes: remoteIncomes)
        }
        return localIncomes
    }
    
    /// Saves a new income entry to the database.
    /// - Parameters:
    ///   - id: The unique identifier of the income.
    ///   - amount: The amount of income.
    ///   - date: The date of the income entry in string format.
    ///   - source: The source of income as a string.
    /// - Returns: A `Bool` with `true` if the income was saved successfully.
    /// - Throws: An `Error` if the operation failed.
    func saveIncome(id: String, amount: Double, date: String, source: String) async throws -> Bool {
        let (localResult, _) = try await (localDatabaseHandler.request(.addIncome(id, amount, date, source)), remoteDatabaseHandler?.request(.addIncome(id, amount, date, source)))
        return try handleResponse(localResult)
    }
    
    /// Updates an existing income entry in the database.
    /// - Parameters:
    ///   - id: The unique identifier of the income entry to update.
    ///   - amount: The new amount of income.
    ///   - date: The updated date of the income entry in string format.
    ///   - source: The updated source of income as a string.
    /// - Returns: A `Bool` with `true` if the update was successful.
    /// - Throws: An `Error` if the operation failed.
    func updateIncome(id: String, amount: Double, date: String, source: String) async throws -> Bool {
        let (localResult, _) = try await (localDatabaseHandler.request(.updateIncome(id, amount, date, source)), remoteDatabaseHandler?.request(.updateIncome(id, amount, date, source)))
        return try handleResponse(localResult)
    }
    
    /// Deletes a specific income entry from the database.
    /// - Parameter id: The unique identifier of the income entry to delete.
    /// - Returns: A `Bool` with `true` if the income was deleted successfully.
    /// - Throws: An `Error` if the operation failed.
    func deleteIncome(id: String) async throws -> Bool {
        let (localResult, _) = try await (localDatabaseHandler.request(.deleteIncome(id)), remoteDatabaseHandler?.request(.deleteIncome(id)))
        return try handleResponse(localResult)
    }
    
    /// Deletes all income records from the database.
    /// - Returns: A `Bool` with `true` if all incomes were deleted successfully
    /// - Throws: An `Error` if the operation failed.
    func deleteAllIncomes() async throws -> Bool {
        let (localResult, _) = try await (localDatabaseHandler.request(.deleteAllIncome), remoteDatabaseHandler?.request(.deleteAllIncome))
        return try handleResponse(localResult)
    }
    
    /// Synchronize both incomes and expenses from remote to local.
    func syncLocalWithRemote() async {
        await syncLocalIncomesWithRemote()
        await syncLocalExpensesWithRemote()
    }
    
    /// Synchronizes expenses from the remote database to the local database.
    /// It checks for any expenses present in remote but missing in local and adds them.
    private func syncLocalExpensesWithRemote() async {
        do {
            if let remoteResult = try await remoteDatabaseHandler?.request(.getExpenses) {
                let remoteExpenses: [Expense] = try handleResponse(remoteResult)
                let localResult = try await localDatabaseHandler.request(.getExpenses)
                let localExpenses: [Expense] = try handleResponse(localResult)
                let localExpenseSet = Set(localExpenses.map { $0.id })
                for expense in remoteExpenses where !localExpenseSet.contains(expense.id) {
                    _ = try await localDatabaseHandler.request(
                        .addExpense(
                            expense.id,
                            expense.name,
                            expense.amount,
                            expense.date,
                            expense.category.rawValue,
                            expense.note
                        )
                    )
                }
            }
        } catch {
            print("Error synchronizing local expenses with remote: \(error.localizedDescription)")
        }
    }
    
    /// Synchronizes incomes from the remote database to the local database.
    /// Only incomes missing in local are added.
    private func syncLocalIncomesWithRemote() async {
        do {
            if let remoteResult = try await remoteDatabaseHandler?.request(.getIncomes) {
                let remoteIncomes: [Income] = try handleResponse(remoteResult)
                let localResult = try await localDatabaseHandler.request(.getIncomes)
                let localIncomes: [Income] = try handleResponse(localResult)
                let localIncomeSet = Set(localIncomes.map { $0.id })
                for income in remoteIncomes where !localIncomeSet.contains(income.id) {
                    _ = try await localDatabaseHandler.request(
                        .addIncome(
                            income.id,
                            income.amount,
                            income.date,
                            income.source.rawValue
                        )
                    )
                }
            }
        } catch {
            print("Error synchronizing local incomes with remote: \(error.localizedDescription)")
        }
    }
    
    /// Synchronize both incomes and expenses from local to remote.
    func syncRemoteWithLocal() async {
        await syncRemoteExpensesWithLocal()
        await syncRemoteIncomesWithLocal()
    }
    
    /// Synchronizes expenses from the local database to the remote database.
    /// Expenses found in local but missing remotely are pushed to the remote database.
    private func syncRemoteExpensesWithLocal() async {
        do {
            var remoteExpenses: [Expense] = []
            if let remoteResult = try await remoteDatabaseHandler?.request(.getExpenses) {
                remoteExpenses = try handleResponse(remoteResult)
            }
            let localResult = try await localDatabaseHandler.request(.getExpenses)
            let localExpenses: [Expense] = try handleResponse(localResult)
            await syncRemoteWithLocal(localExpenses: localExpenses, remoteExpenses: remoteExpenses)
        } catch {
            print("Error synchronizing remote with local expenses: \(error.localizedDescription)")
        }
    }
    
    /// Synchronizes incomes from the local database to the remote database.
    /// Incomes found in local but not in remote are pushed.
    private func syncRemoteIncomesWithLocal() async {
        do {
            var remoteIncomes: [Income] = []
            if let remoteResult = try await remoteDatabaseHandler?.request(.getIncomes) {
                remoteIncomes = try handleResponse(remoteResult)
            }
            let localResult = try await localDatabaseHandler.request(.getIncomes)
            let localIncomes: [Income] = try handleResponse(localResult)
            await syncRemoteWithLocal(localIncomes: localIncomes, remoteIncomes: remoteIncomes)
        } catch {
            print("Error synchronizing remote with local incomes: \(error.localizedDescription)")
        }
    }
    
    /// Synchronizes expenses from the local database to the remote database.
    ///
    /// This function compares local and remote expenses using their `id`s and uploads
    /// any local expense that does not exist in the remote store.
    ///
    /// - Parameters:
    ///   - localExpenses: An array of `Expense` objects stored locally.
    ///   - remoteExpenses: An array of `Expense` objects fetched from the remote source.
    private func syncRemoteWithLocal(localExpenses: [Expense], remoteExpenses: [Expense]) async {
        // Create a set of remote expense IDs for fast lookup.
        let remoteExpenseSet = Set(remoteExpenses.map { $0.id })
        
        // Iterate over each local expense and sync it if it's missing remotely.
        for expense in localExpenses where !remoteExpenseSet.contains(expense.id) {
            do {
                _ = try await remoteDatabaseHandler?.request(
                    .addExpense(
                        expense.id,
                        expense.name,
                        expense.amount,
                        expense.date,
                        expense.category.rawValue,
                        expense.note
                    )
                )
            } catch {
                print("Error synchronizing remote with local expenses: \(error.localizedDescription)")
            }
        }
    }

    /// Synchronizes incomes from the local database to the remote database.
    ///
    /// This function compares local and remote incomes using their `id`s and uploads
    /// any local income that does not exist in the remote store.
    ///
    /// - Parameters:
    ///   - localIncomes: An array of `Income` objects stored locally.
    ///   - remoteIncomes: An array of `Income` objects fetched from the remote source.
    private func syncRemoteWithLocal(localIncomes: [Income], remoteIncomes: [Income]) async {
        // Create a set of remote income IDs for fast lookup.
        let remoteIncomeSet = Set(remoteIncomes.map { $0.id })
        
        // Iterate over each local income and sync it if it's missing remotely.
        for income in localIncomes where !remoteIncomeSet.contains(income.id) {
            do {
                _ = try await remoteDatabaseHandler?.request(
                    .addIncome(
                        income.id,
                        income.amount,
                        income.date,
                        income.source.rawValue
                    )
                )
            } catch {
                print("Error synchronizing remote with local incomes: \(error.localizedDescription)")
            }
        }
    }

    /// Generic method to handle response decoding.
    private func handleResponse<T: Codable>(_ data: Data) throws -> T {
        let response = try JSONDecoder().decode(Response<T>.self, from: data)
        return response.data
    }
}
