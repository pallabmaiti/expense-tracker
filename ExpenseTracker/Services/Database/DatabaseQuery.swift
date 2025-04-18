//
//  DatabaseQuery.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 28/03/25.
//

import Foundation

/// An enumeration representing different `DatabaseQuery` operations for managing expenses.
enum DatabaseQuery {
    
    /// Retrieves the list of all expenses.
    case getExpenses
    
    /// Adds a new expense.
    /// - Parameters:
    ///   - name: The name or description of the expense.
    ///   - amount: The amount spent.
    ///   - date: The date of the expense in `yyyy-MM-dd` format.
    ///   - category: The category of the expense.
    ///   - note: Additional details or comments about the expense.
    case addExpense(String, Double, String, String, String)
    
    /// Updates an existing expense.
    /// - Parameters:
    ///   - id: The unique identifier of the expense.
    ///   - name: The updated name or description of the expense.
    ///   - amount: The updated amount spent.
    ///   - date: The updated date of the expense in `yyyy-MM-dd` format.
    ///   - category: The updated category of the expense.
    ///   - note: The updated details or comments about the expense.
    case updateExpense(String, String, Double, String, String, String)
    
    /// Deletes an expense by its unique identifier.
    /// - Parameter id: The unique identifier of the expense to be deleted.
    case deleteExpense(String)
    
    /// Deletes all stored expenses.
    case deleteAllExpenses
    
    /// Fetches all income records.
    case getIncomes
    
    /// Adds a new income entry.
    /// - Parameters:
    ///   - amount: The amount of income.
    ///   - date: The date of the income entry.
    ///   - source: The source of income (e.g., Salary, Business, etc.).
    case addIncome(Double, String, String)
    
    /// Updates an existing income entry.
    /// - Parameters:
    ///   - id: The existing unique identifier of the income.
    ///   - amount: The updated income amount.
    ///   - date: The updated date.
    ///   - source: The updated source.
    case updateIncome(String, Double, String, String)
    
    /// Deletes a specific income entry.
    /// - Parameter id: The unique identifier of the income to be deleted.
    case deleteIncome(String)
    
    /// Deletes all income records from the database.
    case deleteAllIncome
}
