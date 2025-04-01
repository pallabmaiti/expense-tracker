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
    
    /// Initializes the database by loading stored expenses from `UserDefaults`.
    init() {
        if let data = UserDefaults.standard.data(forKey: "Expenses") {
            if let decode = try? JSONDecoder().decode([DatabaseExpense].self, from: data) {
                _expenses = decode
                return
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
}
