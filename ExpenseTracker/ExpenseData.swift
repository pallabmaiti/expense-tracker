//
//  ExpenseData.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 28/03/25.
//

import Foundation

/// An enumeration representing different categories of expenses.
///
/// Each case corresponds to a specific type of expense, such as food, entertainment, travel, etc.
/// The raw value of each case is a `String` describing the expense category.
/// This enum conforms to `CaseIterable` (allowing iteration over all cases) and `Codable` (enabling easy encoding and decoding).
///
/// Example usage:
/// ```swift
/// let expenseType = ExpenseType.food
/// print(expenseType.rawValue) // Output: "Food"
/// ```
enum ExpenseType: String, CaseIterable, Codable {
    /// Represents food-related expenses.
    case food = "Food"
    /// Represents expenses for entertainment.
    case entertainment = "Entertainment"
    /// Represents travel-related expenses.
    case travel = "Travel"
    /// Represents shopping expenses.
    case shopping = "Shopping"
    /// Represents health-related expenses.
    case health = "Health"
    /// Represents any other type of expense.
    case other = "Other"
}

/// A structure representing an individual expense entry.
///
/// Conforms to `Identifiable` (for use in SwiftUI) and `Codable` (for easy encoding and decoding).
///
/// Example usage:
/// ```swift
/// let expense = Expense(id: UUID().uuidString, name: "Lunch", amount: 250.0, date: Date(), type: .food, note: "Had lunch at a restaurant")
/// ```
struct Expense: Identifiable, Codable {
    
    /// A unique identifier for the expense.
    let id: String
    /// The name or description of the expense.
    let name: String
    /// The amount spent on the expense.
    let amount: Double
    /// The stored date in string format.
    private let _date: String
    /// The actual date of the expense, converted from `_date`.
    var date: Date {
        _date.toDate()
    }
    
    /// The stored expense type as a string.
    private let _type: String
    /// The expense type, converted from `_type`, defaults to `.other` if an invalid type is encountered.
    var type: ExpenseType {
        ExpenseType(rawValue: _type) ?? .other
    }
    
    /// Any additional notes or remarks about the expense.
    let note: String
    
    /// The coding keys used for encoding and decoding.
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case amount = "amount"
        case _date = "date"
        case _type = "type"
        case note = "note"
    }
    
    /// Initializes a new `Expense` instance.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the expense.
    ///   - name: The name or description of the expense.
    ///   - amount: The amount spent.
    ///   - date: The date of the expense.
    ///   - type: The category of the expense.
    ///   - note: Additional notes about the expense.
    init(id: String, name: String, amount: Double, date: Date, type: ExpenseType, note: String) {
        self.id = id
        self.name = name
        self.amount = amount
        self._date = date.formattedString()
        self._type = type.rawValue
        self.note = note
    }
}

/// A structure representing expenses grouped by year and month.
///
/// The `expenses` property organizes expenses by month using the nested `Expenses` struct.
///
/// Example usage:
/// ```swift
/// let yearlyExpenses = ExpenseData(year: 2025, expenses: ExpenseData.Expenses(january: [Expense(...)]))
/// ```
struct ExpenseData: Codable {
    
    /// A structure containing lists of expenses for each month.
    struct Expenses: Codable {
        /// List of expenses for January.
        var january: [Expense] = []
        /// List of expenses for February.
        var february: [Expense] = []
        /// List of expenses for March.
        var march: [Expense] = []
        /// List of expenses for April.
        var april: [Expense] = []
        /// List of expenses for May.
        var may: [Expense] = []
        /// List of expenses for June.
        var june: [Expense] = []
        /// List of expenses for July.
        var july: [Expense] = []
        /// List of expenses for August.
        var august: [Expense] = []
        /// List of expenses for September.
        var september: [Expense] = []
        /// List of expenses for October.
        var october: [Expense] = []
        /// List of expenses for November.
        var november: [Expense] = []
        /// List of expenses for December.
        var december: [Expense] = []
    }
    
    /// The year in which the expenses were recorded.
    let year: Int
    /// The expenses categorized by month.
    let expenses: Expenses
}

extension Expense {
    static var sample = Expense(id: UUID().uuidString, name: "Test Expense", amount: 100.0, date: Date(), type: .food, note: "Test Note")
}

extension ExpenseData {
    static var sample: ExpenseData {
        return .init(year: 2025, expenses: .init(january: [.sample, .sample], february: [.sample]))
    }
}

/*
 [
    {
        "year": 2025,
        "expenses": {
            "january": [],
            "february": []
        }
    },
    {
        "year": 2024,
        "expenses": {
            "january": [],
            "february": []
        }
    }
 ]
 */
