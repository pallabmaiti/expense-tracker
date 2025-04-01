//
//  DatabaseWorker.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 28/03/25.
//

import Foundation

/// An enumeration representing the months of the year.
///
/// Each case corresponds to a month and is assigned its respective numerical value (1 for January, 2 for February, etc.).
/// This enum conforms to `CaseIterable`, allowing iteration over all months.
///
/// Example usage:
/// ```swift
/// let currentMonth = Month.january
/// print(currentMonth.name) // Output: "January"
/// ```
enum Month: Int, CaseIterable {
    
    /// Represents the month of January (1).
    case january = 1
    /// Represents the month of February (2).
    case february = 2
    /// Represents the month of March (3).
    case march = 3
    /// Represents the month of April (4).
    case april = 4
    /// Represents the month of May (5).
    case may = 5
    /// Represents the month of June (6).
    case june = 6
    /// Represents the month of July (7).
    case july = 7
    /// Represents the month of August (8).
    case august = 8
    /// Represents the month of September (9).
    case september = 9
    /// Represents the month of October (10).
    case october = 10
    /// Represents the month of November (11).
    case november = 11
    /// Represents the month of December (12).
    case december = 12

    /// Returns the full name of the month as a string.
    ///
    /// Example usage:
    /// ```swift
    /// let month = Month.march
    /// print(month.name) // Output: "March"
    /// ```
    var name: String {
        switch self {
        case .january:
            return "January"
        case .february:
            return "February"
        case .march:
            return "March"
        case .april:
            return "April"
        case .may:
            return "May"
        case .june:
            return "June"
        case .july:
            return "July"
        case .august:
            return "August"
        case .september:
            return "September"
        case .october:
            return "October"
        case .november:
            return "November"
        case .december:
            return "December"
        }
    }
}

/// A class responsible for handling expense-related operations within a `Database`.
///
/// This class acts as an intermediary between the DatabaseQuery layer and the actual database,
/// performing data manipulation and ensuring structured responses.
class DatabaseWorker {
    
    /// The database instance that stores and retrieves expense data.
    let database: Database
    
    /// Initializes a `DatabaseWorker` with a specified database.
    /// - Parameter datebase: The database that will be used for storing and managing expenses.
    init(datebase: Database) {
        self.database = datebase
    }
    
    /// Fetches all expense data from the database and structures it in a year-wise and month-wise format.
    ///
    /// - Returns: A dictionary containing the expense data structured by year and month.
    func fetchExpenseData() -> [String: Any] {
        let storedExpenses = database.expenses
        var data = [[String: Any]]()
        
        // Iterates through years from 2999 to 2000 (reversed order)
        for i in (2000...2999).reversed() {
            let filteredStoredExpenses = storedExpenses.filter { $0.year == i }
            guard !filteredStoredExpenses.isEmpty else { continue }
            
            var expenses = [String: [[String: Any]]]()
            
            // Iterates through all months to structure expenses by month
            for month in Month.allCases {
                let storedExpensesForMonth = filteredStoredExpenses.filter { $0.month == month.rawValue }
                if !storedExpensesForMonth.isEmpty {
                    let expensesForMonth: [[String: Any]] = storedExpensesForMonth.map {
                        [
                            "id": $0.id,
                            "name": $0.name,
                            "amount": $0.amount,
                            "date": $0.date,
                            "type": $0.type,
                            "note": $0.note
                        ]
                    }
                    expenses[month.name.lowercased()] = expensesForMonth
                } else {
                    expenses[month.name.lowercased()] = []
                }
            }
            
            let expenseData = [
                "year": i,
                "expenses": expenses
            ] as [String: Any]
            
            data.append(expenseData)
        }
        
        return ["data": data]
    }
    
    /// Saves a new expense entry into the database.
    ///
    /// - Parameters:
    ///   - name: The name or description of the expense.
    ///   - amount: The amount of money spent.
    ///   - date: The date of the expense in `yyyy-MM-dd` format.
    ///   - type: The category or type of the expense.
    ///   - note: Additional notes about the expense.
    /// - Throws: An error if the expense data is invalid.
    /// - Returns: A dictionary confirming the operation success.
    func saveExpense(name: String, amount: Double, date: String, type: String, note: String) throws -> [String: Any] {
        let databaseExpense: DatabaseExpense = try .init(name: name, amount: amount, date: date, type: type, note: note)
        database.addExpense(databaseExpense)
        return ["data": true]
    }
    
    /// Deletes an expense from the database.
    ///
    /// - Parameter id: The unique identifier of the expense to delete.
    /// - Throws: `ExpenseTrackerError.dataNotFound` if the expense does not exist.
    /// - Returns: A dictionary confirming the deletion.
    func deleteExpense(id: String) throws -> [String: Any] {
        guard let index = database.expenses.firstIndex(where: { $0.id == id }) else {
            throw ExpenseTrackerError.dataNotFound
        }
        database.deleteExpense(at: index)
        return ["data": true]
    }
    
    /// Updates an existing expense in the database.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the expense to update.
    ///   - name: The updated name or description of the expense.
    ///   - amount: The updated amount spent.
    ///   - date: The updated date of the expense in `yyyy-MM-dd` format.
    ///   - type: The updated category or type of the expense.
    ///   - note: The updated details about the expense.
    /// - Throws: `ExpenseTrackerError.dataNotFound` if the expense does not exist.
    /// - Returns: A dictionary confirming the update.
    func updateExpense(id: String, name: String, amount: Double, date: String, type: String, note: String) throws -> [String: Any] {
        guard let index = database.expenses.firstIndex(where: { $0.id == id }) else {
            throw ExpenseTrackerError.dataNotFound
        }
        let newExpense: DatabaseExpense = try .init(id: id, name: name, amount: amount, date: date, type: type, note: note)
        database.updateExpense(at: index, with: newExpense)
        return ["data": true]
    }
    
    /// Deletes all stored expenses in the database.
    ///
    /// - Returns: A dictionary confirming the deletion of all expenses.
    func deleteAllExpenses() -> [String: Any] {
        database.clearExpenses()
        return ["data": true]
    }
}
