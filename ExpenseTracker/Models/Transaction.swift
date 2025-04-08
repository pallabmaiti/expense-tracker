//
//  Transaction.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 03/04/25.
//

import Foundation

/// A protocol that represents a financial transaction, such as an expense or income.
/// Conforming types must have a unique identifier, an amount, and a date.
protocol Transaction: Identifiable, Codable {
    /// A unique identifier for the transaction.
    var id: String { get }
    
    /// The monetary amount of the transaction.
    var amount: Double { get }
    
    /// The date of the transaction in string format.
    ///
    /// - Format: `"yyyy-MM-dd"` (Default format).
    var date: String { get }
    
    /// A computed property that converts the string-based date into a `Date` object.
    var formattedDate: Date { get }
}

/// An extension that provides a default implementation for `formattedDate`.
extension Transaction {
    /// Converts the `date` string into a `Date` object using the default format.
    ///
    /// - Returns: A `Date` object representing the transaction date.
    var formattedDate: Date {
        date.toDate()
    }
}

/// A model representing an income entry in the income tracker.
///
/// The `Income` struct is used to store information about different sources of income, including the amount received,
/// the category of income (`Source`), and the date of receipt.
///
/// - Conforms to `Identifiable` to allow unique identification within lists.
/// - Conforms to `Codable` for easy encoding/decoding when storing or retrieving data.
struct Income: Transaction {
    /// Unique identifier for the income entry.
    let id: String
    
    /// The amount of income received.
    let amount: Double
    
    /// The stored source type as a string.
    private let _source: String
    /// The source of the income (e.g., Salary, Business, Interest, etc.)., converted from `_source`,
    /// defaults to `.other` if an invalid type is encountered.
    var source: Source {
        Source(rawValue: _source) ?? .other
    }
    
    /// The stored date in string format.
    let date: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case _source = "source"
        case date
    }
    
    /// Initializes a new `Income` instance.
    /// - Parameters:
    ///   - id: A unique identifier for the income (default: `UUID().uuidString`).
    ///   - amount: The amount of income received.
    ///   - source: The category of the income.
    ///   - date: The date when the income was received.
    init(id: String, amount: Double, source: Source, date: Date) {
        self.id = id
        self.amount = amount
        self._source = source.rawValue
        self.date = date.formattedString()
    }
}

extension Income {
    static var sample: Income {
        .init(
            id: UUID().uuidString,
            amount: 10000.0,
            source: .salary,
            date: Date()
        )
    }
}

/// A structure representing an individual expense entry.
///
/// Conforms to `Identifiable` (for use in SwiftUI) and `Codable` (for easy encoding and decoding).
///
/// Example usage:
/// ```swift
/// let expense = Expense(id: UUID().uuidString, name: "Lunch", amount: 250.0, date: Date(), category: .food, note: "Had lunch at a restaurant")
/// ```
struct Expense: Transaction {
    /// A unique identifier for the expense.
    let id: String
    /// The name or description of the expense.
    let name: String
    /// The amount spent on the expense.
    let amount: Double
    /// The stored date in string format.
    let date: String

    /// The stored expense category as a string.
    private let _category: String
    /// The expense category, converted from `_category`, defaults to `.other` if an invalid type is encountered.
    var category: Category {
        Category(rawValue: _category) ?? .other
    }
    
    /// Any additional notes or remarks about the expense.
    let note: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case amount
        case date
        case _category = "category"
        case note
    }
    
    /// Initializes a new `Expense` instance.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the expense.
    ///   - name: The name or description of the expense.
    ///   - amount: The amount spent.
    ///   - date: The date of the expense.
    ///   - category: The category of the expense.
    ///   - note: Additional notes about the expense.
    init(id: String, name: String, amount: Double, date: Date, category: Category, note: String) {
        self.id = id
        self.name = name
        self.amount = amount
        self.date = date.formattedString()
        self._category = category.rawValue
        self.note = note
    }
}

extension Expense {
    static var sample: Expense {
        .init(
            id: UUID().uuidString,
            name: "Groceries",
            amount: 100.0,
            date: Date(),
            category: .food,
            note: "Weekly shopping"
        )
    }
}

extension [Expense] {
    
    /// Sorts the array of `Expense` items based on the specified sorting option and order.
    ///
    /// - Parameters:
    ///   - sortingOption: The criterion by which the expenses should be sorted (date, amount, or name).
    ///   - isDescending: A Boolean value indicating the order direction. `true` for descending, `false` for ascending.
    ///
    /// - Returns: A sorted array of `Expense` items.
    func sorted(by sortingOption: SortingOption, isDescending: Bool) -> [Expense] {
        switch (sortingOption, isDescending) {
        
        case (.date, true):
            // Sort by date — newest first
            return self.sorted { $0.formattedDate > $1.formattedDate }
            
        case (.date, false):
            // Sort by date — oldest first
            return self.sorted { $0.formattedDate < $1.formattedDate }
            
        case (.amount, true):
            // Sort by amount — highest first
            return self.sorted { $0.amount > $1.amount }
            
        case (.amount, false):
            // Sort by amount — lowest first
            return self.sorted { $0.amount < $1.amount }
            
        case (.name, true):
            // Sort by name — reverse alphabetical order (Z to A)
            return self.sorted { $0.name > $1.name }
            
        case (.name, false):
            // Sort by name — alphabetical order (A to Z)
            return self.sorted { $0.name < $1.name }
        }
    }
    
    /// Filters the array of `Expense` objects to only include those that belong to the current month and year.
    ///
    /// - Returns: A new array of `Expense` objects from the current calendar month.
    ///
    /// - Note: Uses the "MMMM yyyy" format to compare month and year (e.g., "April 2025").
    func filterByCurrentMonth() -> [Expense] {
        let currentMonth = Date().formattedString(dateFormat: "MMMM yyyy")
        return self.filter {
            $0.formattedDate
                .formattedString(dateFormat: "MMMM yyyy")
                .localizedCaseInsensitiveContains(currentMonth)
        }
    }
}

extension [Income] {
    
    /// Sorts the array of `Income` objects based on a selected `SortingOption` and `Ordering`.
    ///
    /// - Parameters:
    ///   - sortingOption: The option by which to sort the incomes (e.g., date, amount).
    ///   - isDescending: A Boolean value indicating the order direction. `true` for descending, `false` for ascending.
    ///
    /// - Returns: A sorted array of `Income` items.
    func sorted(by sortingOption: SortingOption, isDescending: Bool) -> [Income] {
        switch (sortingOption, isDescending) {
        case (.date, true):
            // Sort by newest date first
            return self.sorted { $0.formattedDate > $1.formattedDate }
            
        case (.date, false):
            // Sort by oldest date first
            return self.sorted { $0.formattedDate < $1.formattedDate }
            
        case (.amount, true):
            // Sort by highest income amount first
            return self.sorted { $0.amount > $1.amount }
            
        case (.amount, false):
            // Sort by lowest income amount first
            return self.sorted { $0.amount < $1.amount }
            
        default:
            // Sorting by name is not applicable for Income, return as-is
            return self
        }
    }
    
    /// Filters the income entries to include only those that were received in the current month and year.
    ///
    /// - Returns: An array of `Income` objects that belong to the current calendar month.
    ///
    /// - Note: The date is formatted as "MMMM yyyy" (e.g., "April 2025") to ensure a match based on both month and year.
    func filterByCurrentMonth() -> [Income] {
        let currentMonth = Date().formattedString(dateFormat: "MMMM yyyy")
        return self.filter {
            $0.formattedDate
                .formattedString(dateFormat: "MMMM yyyy")
                .localizedCaseInsensitiveContains(currentMonth)
        }
    }
}

