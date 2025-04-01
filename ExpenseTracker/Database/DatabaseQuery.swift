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
    ///   - type: The category or type of the expense.
    ///   - note: Additional details or comments about the expense.
    case addExpense(String, Double, String, String, String)
    
    /// Updates an existing expense.
    /// - Parameters:
    ///   - id: The unique identifier of the expense.
    ///   - name: The updated name or description of the expense.
    ///   - amount: The updated amount spent.
    ///   - date: The updated date of the expense in `yyyy-MM-dd` format.
    ///   - type: The updated category or type of the expense.
    ///   - note: The updated details or comments about the expense.
    case updateExpense(String, String, Double, String, String, String)
    
    /// Deletes an expense by its unique identifier.
    /// - Parameter id: The unique identifier of the expense to be deleted.
    case deleteExpense(String)
    
    /// Deletes all stored expenses.
    case deleteAllExpenses
}
