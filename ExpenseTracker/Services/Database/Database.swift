//
//  Database.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 28/03/25.
//

import Foundation

/// A protocol defining a basic expense database.
protocol Database {
    
    /// Return an array of stored expenses.
    func fetchExpenses() async throws -> [DatabaseExpense]
    
    /// Adds a new expense to the database.
    /// - Parameter expense: The expense to be added.
    func addExpense(_ expense: DatabaseExpense) async throws
    
    /// Deletes an expense at the specified index.
    /// - Parameter id: The id of the expense to be removed.
    func deleteExpense(_ id: String) async throws
    
    /// Updates an existing expense at the given index with a new expense.
    /// - Parameters:
    ///   - id: The id of the expense to be updated.
    ///   - newExpense: The new expense data to replace the existing one.
    func updateExpense(for id: String, with newExpense: DatabaseExpense) async throws
    
    /// Clears all stored expenses from the database.
    func clearExpenses() async throws
    
    /// An array of `DatabaseIncome` representing all stored incomes.
    func fetchIncomes() async throws -> [DatabaseIncome]
    
    /// Adds a new income entry to the database.
    /// - Parameter income: The `DatabaseIncome` object to be added.
    func addIncome(_ income: DatabaseIncome) async throws
    
    /// Deletes an income entry from the database at a specific index.
    /// - Parameter id: The id of the income entry to be deleted.
    func deleteIncome(_ id: String) async throws
    
    /// Updates an existing income entry at a specific index with new data.
    /// - Parameters:
    ///   - id: The id of the income entry to be updated.
    ///   - newIncome: The updated `DatabaseIncome` object.
    func updateIncome(for id: String, with newIncome: DatabaseIncome) async throws
    
    /// Removes all income entries from the database.
    func clearIncomes() async throws
}

/// A concrete implementation of `Database` that persists expenses using `UserDefaults`.
class UserDefaultsDatabase: Database {
    
    /// A private array of expenses, automatically saved to `UserDefaults` when modified.
    private var _expenses: [DatabaseExpense] = [] {
        didSet {
            if let data = try? JSONEncoder().encode(_expenses) {
                userDefaults.set(data, forKey: "Expenses")
            }
        }
    }
    
    private var _incomes: [DatabaseIncome] = [] {
        didSet {
            if let data = try? JSONEncoder().encode(_incomes) {
                userDefaults.set(data, forKey: "Incomes")
            }
        }
    }
    
    /// Initializes the database by loading stored expenses from `UserDefaults`.
    init() {
        self.userDefaults = .standard
        
        if let data = userDefaults.data(forKey: "Expenses") {
            if let decode = try? JSONDecoder().decode([DatabaseExpense].self, from: data) {
                _expenses = decode
            }
        }
        if let data = userDefaults.data(forKey: "Incomes") {
            if let decode = try? JSONDecoder().decode([DatabaseIncome].self, from: data) {
                _incomes = decode
            }
        }
    }
    
    /// A private constant that holds the reference to the `UserDefaults` instance.
    /// This can be either a named suite (for shared data between app groups) or the standard UserDefaults.
    private let userDefaults: UserDefaults
    
    /// Initializes a new instance with a specific suite name for `UserDefaults`.
    /// - Parameter suiteName: A string identifying the suite (app group or container) to be used.
    ///   If the suite name is invalid or not found, the initializer falls back to `.standard` UserDefaults.
    ///   This is useful when you want to share data between the main app and its extensions (like widgets or watch apps).
    init(suiteName: String) {
        self.userDefaults = UserDefaults(suiteName: suiteName) ?? .standard
        
        if let data = userDefaults.data(forKey: "Expenses") {
            if let decode = try? JSONDecoder().decode([DatabaseExpense].self, from: data) {
                _expenses = decode
            }
        }
        if let data = userDefaults.data(forKey: "Incomes") {
            if let decode = try? JSONDecoder().decode([DatabaseIncome].self, from: data) {
                _incomes = decode
            }
        }
    }
    
    /// A serial dispatch queue to ensure thread-safe access to the expenses array.
    private let queue = DispatchQueue(label: "com.ExpenseTracker.UserDefaultsDatabase")
    
    /// Returns a thread-safe copy of the stored expenses.
    func fetchExpenses() async throws -> [DatabaseExpense] {
        _expenses
    }
    
    /// Adds a new expense to the database and updates `UserDefaults`.
    /// - Parameter expense: The expense to be added.
    func addExpense(_ expense: DatabaseExpense) async throws {
        _expenses.append(expense)
    }
    
    /// Deletes an expense at the specified index and updates `UserDefaults`.
    /// - Parameter id: The id of the expense to be removed.
    func deleteExpense(_ id: String) async throws {
        guard let index = _expenses.firstIndex(where: { $0.id == id }) else { throw ExpenseTrackerError.dataNotFound }
        _expenses.remove(at: index)
    }
    
    /// Updates an existing expense at the given index with a new expense and saves the change to `UserDefaults`.
    /// - Parameters:
    ///   - id: The id of the expense to be updated.
    ///   - newExpense: The new expense data to replace the existing one.
    func updateExpense(for id: String, with newExpense: DatabaseExpense) async throws {
        guard let index = _expenses.firstIndex(where: { $0.id == id }) else { throw ExpenseTrackerError.dataNotFound }
        _expenses[index] = newExpense
    }
    
    /// Removes all expenses from the database and updates `UserDefaults`.
    func clearExpenses() async throws {
        _expenses.removeAll()
    }
    
    /// A thread-safe computed property to access the stored incomes.
    func fetchIncomes() async throws -> [DatabaseIncome] {
        _incomes
    }
    
    /// Adds a new income entry to the database in a thread-safe manner.
    /// - Parameter income: The `DatabaseIncome` object to be added.
    func addIncome(_ income: DatabaseIncome) async throws {
        _incomes.append(income)
    }
    
    /// Updates an existing income entry at a specific index in a thread-safe manner.
    /// - Parameters:
    ///   - id: The id of the income entry to be updated.
    ///   - newIncome: The updated `DatabaseIncome` object.
    func updateIncome(for id: String, with newIncome: DatabaseIncome) async throws {
        guard let index = _incomes.firstIndex(where: { $0.id == id }) else { throw ExpenseTrackerError.dataNotFound }
        _incomes[index] = newIncome
    }
    
    /// Deletes an income entry at a given index in a thread-safe manner.
    /// - Parameter id: The id of the income entry to be deleted.
    func deleteIncome(_ id: String) async throws {
        guard let index = _incomes.firstIndex(where: { $0.id == id }) else { throw ExpenseTrackerError.dataNotFound }
        _incomes.remove(at: index)
    }
    
    /// Clears all income records from the database in a thread-safe manner.
    func clearIncomes() async throws {
        _incomes.removeAll()
    }
}

/// `InMemoryDatabase` is an implementation of the `Database` protocol that simulates a local in-memory database.
/// It stores expenses in an array and provides methods to add, delete, update, and clear expenses.
/// It uses a `DispatchQueue` for thread-safety when modifying the underlying data.
class InMemoryDatabase: Database {
    
    /// A private array holding the in-memory expenses.
    private var _expenses: [DatabaseExpense] = [.sample1, .sample2, .sample3]
    
    /// A `DispatchQueue` used for synchronizing access to the in-memory database to ensure thread safety.
    private let queue = DispatchQueue(label: "com.ExpenseTracker.InMemoryDatabase")
    
    /// A computed property that returns the list of expenses in the database.
    /// Access is synchronized using the `queue`.
    func fetchExpenses() async throws -> [DatabaseExpense] {
        _expenses
    }
    
    /// Adds a new expense to the database.
    /// - Parameter expense: The `DatabaseExpense` to be added.
    func addExpense(_ expense: DatabaseExpense) async throws {
        _expenses.append(expense) // Adds the expense to the in-memory list
    }
    
    /// Deletes an expense from the database at a specific index.
    /// - Parameter id: The id of the expense to be deleted.
    func deleteExpense(_ id: String) async throws {
        guard let index = _expenses.firstIndex(where: { $0.id == id }) else { return }
        _expenses.remove(at: index)
    }
    
    /// Updates an existing expense at a specific index with a new expense.
    /// - Parameters:
    ///   - id: The id of the expense to be updated.
    ///   - newExpense: The `DatabaseExpense` that will replace the existing expense.
    func updateExpense(for id: String, with newExpense: DatabaseExpense) async throws {
        guard let index = _expenses.firstIndex(where: { $0.id == id }) else { return }
        _expenses[index] = newExpense
    }
    
    /// Clears all expenses from the database.
    func clearExpenses() async throws {
        _expenses.removeAll() // Removes all expenses from the in-memory list
    }
    
    private var _incomes: [DatabaseIncome] = [.sample1, .sample2, .sample3]
    
    /// A computed property that returns the list of incomes in the database.
    /// Access is synchronized using the `queue`.
    func fetchIncomes() async throws -> [DatabaseIncome] {
        _incomes
    }
    
    /// Adds a new income to the database.
    /// - Parameter income: The `DatabaseIncome` to be added.
    func addIncome(_ income: DatabaseIncome) async throws {
        _incomes.append(income)
    }
    
    /// Updates an existing income at a specific index with a new income.
    /// - Parameters:
    ///   - id: The id of the income to be updated.
    ///   - newIncome: The `DatabaseIncome` that will replace the existing income.
    func updateIncome(for id: String, with newIncome: DatabaseIncome) async throws {
        guard let index = _incomes.firstIndex(where: { $0.id == id }) else { return }
        _incomes[index] = newIncome
    }
    
    /// Deletes an income from the database at a specific index.
    /// - Parameter id: The id of the income to be deleted.
    func deleteIncome(_ id: String) async throws {
        guard let index = _incomes.firstIndex(where: { $0.id == id }) else { return }
        _incomes.remove(at: index)
    }
    
    /// Clears all incomes from the database.
    func clearIncomes() async throws {
        _incomes.removeAll()
    }
}
