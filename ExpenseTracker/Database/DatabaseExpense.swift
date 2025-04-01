//
//  DatabaseExpense.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 01/04/25.
//

import Foundation

/// A model representing an expense record stored in the database.
struct DatabaseExpense: Codable {
    
    /// Unique identifier for the expense.
    let id: String
    
    /// The name or description of the expense.
    let name: String
    
    /// The amount spent.
    let amount: Double
    
    /// The date of the expense in `yyyy-MM-dd` format.
    let date: String
    
    /// The type or category of the expense.
    let type: String
    
    /// Additional notes or details about the expense.
    let note: String
    
    /// The year extracted from the date.
    let year: Int
    
    /// The month extracted from the date.
    let month: Int

    /// Initializes a new expense entry.
    /// - Parameters:
    ///   - id: The unique identifier for the expense. Defaults to a new UUID string.
    ///   - name: The name or description of the expense.
    ///   - amount: The amount spent.
    ///   - date: The date of the expense in `yyyy-MM-dd` format.
    ///   - type: The category or type of expense.
    ///   - note: Additional details or comments about the expense.
    /// - Throws:
    ///   - `ExpenseTrackerError.invalidDateFormat` if the date string is not in the correct format.
    ///   - `ExpenseTrackerError.invalidYear` if the year cannot be extracted from the date.
    ///   - `ExpenseTrackerError.invalidMonth` if the month cannot be extracted from the date.
    init(id: String = UUID().uuidString, name: String, amount: Double, date: String, type: String, note: String) throws {
        self.id = id
        self.name = name
        self.amount = amount
        self.date = date
        self.type = type
        self.note = note

        let dateFormatter: DateFormatter = .init()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let expenseDate = dateFormatter.date(from: date) else {
            throw ExpenseTrackerError.invalidDateFormat
        }
        
        let dateComponents: DateComponents = Calendar.current.dateComponents([.year, .month], from: expenseDate)
        
        guard let year = dateComponents.year else {
            throw ExpenseTrackerError.invalidYear
        }
        guard let month = dateComponents.month else {
            throw ExpenseTrackerError.invalidMonth
        }
        
        self.year = year
        self.month = month
    }
}


extension DatabaseExpense {
    static var sample1: DatabaseExpense {
        try! .init(id: UUID().uuidString, name: "Milk", amount: 21.50, date: "2025-03-28", type: "Food", note: "1 litre")
    }
    static var sample2: DatabaseExpense {
        try! .init(id: UUID().uuidString, name: "Bread", amount: 10.50, date: "2025-03-29", type: "Food", note: "1 loaf")
    }
    static var sample3: DatabaseExpense {
        try! .init(id: UUID().uuidString, name: "Eggs", amount: 5.50, date: "2025-03-30", type: "Food", note: "Dozen")
    }
    static var sample4: DatabaseExpense {
        try! .init(id: UUID().uuidString, name: "Coffee", amount: 12.50, date: "2025-03-31", type: "Drink", note: "1 cup")
    }
    
    static var sample5: DatabaseExpense {
        try! .init(id: UUID().uuidString, name: "Chocolate", amount: 15.50, date: "2025-04-01", type: "Food", note: "1 bar")
    }
    static var sample6: DatabaseExpense {
        try! .init(id: UUID().uuidString, name: "Tea", amount: 8.50, date: "2025-04-02", type: "Drink", note: "1 cup")
    }
    static var sample7: DatabaseExpense {
        try! .init(id: UUID().uuidString, name: "Soap", amount: 4.50, date: "2024-12-28", type: "Personal Care", note: "1 bar")
    }
    static var sample8: DatabaseExpense {
        try! .init(id: UUID().uuidString, name: "Shampoo", amount: 7.50, date: "2024-12-29", type: "Personal Care", note: "1 bottle")
    }
}
