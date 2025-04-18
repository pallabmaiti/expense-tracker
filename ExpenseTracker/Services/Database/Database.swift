//
//  Database.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 28/03/25.
//

import Foundation

/// A protocol defining a basic expense database.
protocol Database {
    
    /// An array of stored expenses.
    var expenses: [DatabaseExpense] { get }
    
    /// Adds a new expense to the database.
    /// - Parameter expense: The expense to be added.
    func addExpense(_ expense: DatabaseExpense)
    
    /// Deletes an expense at the specified index.
    /// - Parameter index: The index of the expense to be removed.
    func deleteExpense(at index: Int)
    
    /// Updates an existing expense at the given index with a new expense.
    /// - Parameters:
    ///   - index: The index of the expense to be updated.
    ///   - newExpense: The new expense data to replace the existing one.
    func updateExpense(at index: Int, with newExpense: DatabaseExpense)
    
    /// Clears all stored expenses from the database.
    func clearExpenses()
    
    /// An array of `DatabaseIncome` representing all stored incomes.
    var incomes: [DatabaseIncome] { get }
    
    /// Adds a new income entry to the database.
    /// - Parameter income: The `DatabaseIncome` object to be added.
    func addIncome(_ income: DatabaseIncome)
    
    /// Deletes an income entry from the database at a specific index.
    /// - Parameter index: The index of the income entry to be deleted.
    func deleteIncome(at index: Int)
    
    /// Updates an existing income entry at a specific index with new data.
    /// - Parameters:
    ///   - index: The index of the income entry to be updated.
    ///   - newIncome: The updated `DatabaseIncome` object.
    func updateIncome(at index: Int, with newIncome: DatabaseIncome)
    
    /// Removes all income entries from the database.
    func clearIncomes()
}

/// A concrete implementation of `Database` that persists expenses using `UserDefaults`.
class UserDefaultsDatabase: Database {
    
    /// A private array of expenses, automatically saved to `UserDefaults` when modified.
    private var _expenses: [DatabaseExpense] = [] {
        didSet {
            if let data = try? JSONEncoder().encode(_expenses) {
                UserDefaults.standard.set(data, forKey: "Expenses")
            }
        }
    }
    
    private var _incomes: [DatabaseIncome] = [] {
        didSet {
            if let data = try? JSONEncoder().encode(_incomes) {
                UserDefaults.standard.set(data, forKey: "Incomes")
            }
        }
    }
    
    /// Initializes the database by loading stored expenses from `UserDefaults`.
    init() {
        if let data = UserDefaults.standard.data(forKey: "Expenses") {
            if let decode = try? JSONDecoder().decode([DatabaseExpense].self, from: data) {
                _expenses = decode
            }
        }
        if let data = UserDefaults.standard.data(forKey: "Incomes") {
            if let decode = try? JSONDecoder().decode([DatabaseIncome].self, from: data) {
                _incomes = decode
            }
        }
    }
    
    /// A serial dispatch queue to ensure thread-safe access to the expenses array.
    private let queue = DispatchQueue(label: "com.ExpenseTracker.UserDefaultsDatabase")
    
    /// Returns a thread-safe copy of the stored expenses.
    var expenses: [DatabaseExpense] {
        queue.sync { [weak self] in
            guard let self else { return [] }
            return _expenses
        }
    }
    
    /// Adds a new expense to the database and updates `UserDefaults`.
    /// - Parameter expense: The expense to be added.
    func addExpense(_ expense: DatabaseExpense) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            _expenses.append(expense)
        }
    }
    
    /// Deletes an expense at the specified index and updates `UserDefaults`.
    /// - Parameter index: The index of the expense to be removed.
    func deleteExpense(at index: Int) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            guard index >= 0, index < _expenses.count else { return }
            _expenses.remove(at: index)
        }
    }
    
    /// Updates an existing expense at the given index with a new expense and saves the change to `UserDefaults`.
    /// - Parameters:
    ///   - index: The index of the expense to be updated.
    ///   - newExpense: The new expense data to replace the existing one.
    func updateExpense(at index: Int, with newExpense: DatabaseExpense) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            guard index >= 0, index < _expenses.count else { return }
            _expenses[index] = newExpense
        }
    }
    
    /// Removes all expenses from the database and updates `UserDefaults`.
    func clearExpenses() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            _expenses.removeAll()
        }
    }
    
    /// A thread-safe computed property to access the stored incomes.
    var incomes: [DatabaseIncome] {
        queue.sync { [weak self] in
            guard let self else { return [] }
            return _incomes
        }
    }
    
    /// Adds a new income entry to the database in a thread-safe manner.
    /// - Parameter income: The `DatabaseIncome` object to be added.
    func addIncome(_ income: DatabaseIncome) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            _incomes.append(income)
        }
    }
    
    /// Updates an existing income entry at a specific index in a thread-safe manner.
    /// - Parameters:
    ///   - index: The index of the income entry to be updated.
    ///   - newIncome: The updated `DatabaseIncome` object.
    func updateIncome(at index: Int, with newIncome: DatabaseIncome) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            guard index >= 0, index < _incomes.count else { return }
            _incomes[index] = newIncome
        }
    }
    
    /// Deletes an income entry at a given index in a thread-safe manner.
    /// - Parameter index: The index of the income entry to be deleted.
    func deleteIncome(at index: Int) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            guard index >= 0, index < _incomes.count else { return }
            _incomes.remove(at: index)
        }
    }
    
    /// Clears all income records from the database in a thread-safe manner.
    func clearIncomes() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            _incomes.removeAll()
        }
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
    var expenses: [DatabaseExpense] {
        queue.sync { [weak self] in
            guard let self else { return [] }
            return _expenses
        }
    }
    
    /// Adds a new expense to the database.
    /// - Parameter expense: The `DatabaseExpense` to be added.
    func addExpense(_ expense: DatabaseExpense) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            _expenses.append(expense) // Adds the expense to the in-memory list
        }
    }
    
    /// Deletes an expense from the database at a specific index.
    /// - Parameter index: The index of the expense to be deleted.
    func deleteExpense(at index: Int) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            guard index >= 0, index < _expenses.count else { return }
            _expenses.remove(at: index) // Removes the expense at the given index
        }
    }
    
    /// Updates an existing expense at a specific index with a new expense.
    /// - Parameters:
    ///   - index: The index of the expense to be updated.
    ///   - newExpense: The `DatabaseExpense` that will replace the existing expense.
    func updateExpense(at index: Int, with newExpense: DatabaseExpense) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            guard index >= 0, index < _expenses.count else { return }
            _expenses[index] = newExpense // Updates the expense at the specified index
        }
    }
    
    /// Clears all expenses from the database.
    func clearExpenses() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            _expenses.removeAll() // Removes all expenses from the in-memory list
        }
    }
    
    private var _incomes: [DatabaseIncome] = [.sample1, .sample2, .sample3]
    
    /// A computed property that returns the list of incomes in the database.
    /// Access is synchronized using the `queue`.
    var incomes: [DatabaseIncome] {
        queue.sync { [weak self] in
            guard let self else { return [] }
            return _incomes
        }
    }
    
    /// Adds a new income to the database.
    /// - Parameter income: The `DatabaseIncome` to be added.
    func addIncome(_ income: DatabaseIncome) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            _incomes.append(income)
        }
    }
    
    /// Updates an existing income at a specific index with a new income.
    /// - Parameters:
    ///   - index: The index of the income to be updated.
    ///   - newIncome: The `DatabaseIncome` that will replace the existing income.
    func updateIncome(at index: Int, with newIncome: DatabaseIncome) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            guard index >= 0, index < _incomes.count else { return }
            _incomes[index] = newIncome
        }
    }
    
    /// Deletes an income from the database at a specific index.
    /// - Parameter index: The index of the income to be deleted.
    func deleteIncome(at index: Int) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            guard index >= 0, index < _incomes.count else { return }
            _incomes.remove(at: index)
        }
    }
    
    /// Clears all incomes from the database.
    func clearIncomes() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            _incomes.removeAll()
        }
    }
}
