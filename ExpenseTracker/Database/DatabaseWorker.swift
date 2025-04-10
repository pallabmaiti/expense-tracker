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
    
    /// Fetches all expense data from the database.
    ///
    /// - Returns: A dictionary containing the expense data.
    func fetchExpenses() -> [String: Any] {
        var data = [[String: Any]]()
        
        database.expenses.forEach {
            data.append([
                "id": $0.id,
                "name": $0.name,
                "amount": $0.amount,
                "date": $0.date,
                "category": $0.category,
                "note": $0.note
            ])
        }
        
        return ["data": data]
    }
    
    /// Saves a new expense entry into the database.
    ///
    /// - Parameters:
    ///   - name: The name or description of the expense.
    ///   - amount: The amount of money spent.
    ///   - date: The date of the expense in `yyyy-MM-dd` format.
    ///   - category: The category of the expense.
    ///   - note: Additional notes about the expense.
    /// - Returns: A dictionary confirming the operation success.
    func saveExpense(name: String, amount: Double, date: String, category: String, note: String) -> [String: Any] {
        let databaseExpense: DatabaseExpense = .init(name: name, amount: amount, date: date, category: category, note: note)
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
    ///   - category: The updated category of the expense.
    ///   - note: The updated details about the expense.
    /// - Throws: `ExpenseTrackerError.dataNotFound` if the expense does not exist.
    /// - Returns: A dictionary confirming the update.
    func updateExpense(id: String, name: String, amount: Double, date: String, category: String, note: String) throws -> [String: Any] {
        guard let index = database.expenses.firstIndex(where: { $0.id == id }) else {
            throw ExpenseTrackerError.dataNotFound
        }
        let newExpense: DatabaseExpense = .init(id: id, name: name, amount: amount, date: date, category: category, note: note)
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
    
    /// Fetches all income data from the database.
    ///
    /// - Returns: A dictionary containing the income data.
    func fetchIncomes() -> [String: Any] {
        var data = [[String: Any]]()
        
        database.incomes.forEach {
            data.append([
                "id": $0.id,
                "amount": $0.amount,
                "date": $0.date,
                "source": $0.source,
            ])
        }
        
        return ["data": data]
    }
    
    /// Saves a new income entry to the database.
    /// - Parameters:
    ///   - amount: The amount of the income.
    ///   - date: The date of the income in `String` format.
    ///   - source: The source of income (e.g., Salary, Business, etc.).
    /// - Returns: A dictionary indicating the success of the operation.
    func saveIncome(amount: Double, date: String, source: String) -> [String: Any] {
        let newIncome: DatabaseIncome = .init(amount: amount, date: date, source: source)
        database.addIncome(newIncome)
        return ["data": true]
    }
    
    /// Updates an existing income entry in the database.
    /// - Parameters:
    ///   - id: The unique identifier of the income to update.
    ///   - amount: The new income amount.
    ///   - date: The new income date.
    ///   - note: The updated source of income.
    /// - Throws: `ExpenseTrackerError.dataNotFound` if the income ID does not exist.
    /// - Returns: A dictionary indicating the success of the operation.
    func updateIncome(id: String, amount: Double, date: String, source: String) throws -> [String: Any] {
        guard let index = database.incomes.firstIndex(where: { $0.id == id }) else {
            throw ExpenseTrackerError.dataNotFound
        }
        let newIncome: DatabaseIncome = .init(id: id, amount: amount, date: date, source: source)
        database.updateIncome(at: index, with: newIncome)
        return ["data": true]
    }
    
    /// Deletes an income entry from the database.
    /// - Parameter id: The unique identifier of the income to delete.
    /// - Throws: `ExpenseTrackerError.dataNotFound` if the income ID does not exist.
    /// - Returns: A dictionary indicating the success of the operation.
    func deleteIncome(id: String) throws -> [String: Any] {
        guard let index = database.incomes.firstIndex(where: { $0.id == id }) else {
            throw ExpenseTrackerError.dataNotFound
        }
        database.deleteIncome(at: index)
        return ["data": true]
    }
    
    /// Deletes all income entries from the database.
    /// - Returns: A dictionary indicating the success of the operation.
    func deleteAllIncomes() -> [String: Any] {
        database.clearIncomes()
        return ["data": true]
    }
}
