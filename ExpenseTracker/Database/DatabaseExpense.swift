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
    
    /// The category of the expense.
    let category: String
    
    /// Additional notes or details about the expense.
    let note: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case amount
        case date
        case category = "type"
        case note
    }
    
    /// Initializes a new expense entry.
    /// - Parameters:
    ///   - id: The unique identifier for the expense. Defaults to a new UUID string.
    ///   - name: The name or description of the expense.
    ///   - amount: The amount spent.
    ///   - date: The date of the expense in `yyyy-MM-dd` format.
    ///   - category: The category of expense.
    ///   - note: Additional details or comments about the expense.
    init(id: String = UUID().uuidString, name: String, amount: Double, date: String, category: String, note: String) {
        self.id = id
        self.name = name
        self.amount = amount
        self.date = date
        self.category = category
        self.note = note
    }
}


extension DatabaseExpense {
    static var sample1: DatabaseExpense {
        .init(name: "Milk", amount: 21.50, date: "2025-04-01", category: "Food", note: "1 litre")
    }
    static var sample2: DatabaseExpense {
        .init(name: "Movie", amount: 1000.50, date: "2025-04-05", category: "Entertainment", note: "1 loaf")
    }
    static var sample3: DatabaseExpense {
        .init(name: "Cab", amount: 500.00, date: "2025-04-06", category: "Travel", note: "Dozen")
    }
    static var sample4: DatabaseExpense {
        .init(name: "Coffee", amount: 12.50, date: "2025-03-31", category: "Drink", note: "1 cup")
    }
    
    static var sample5: DatabaseExpense {
        .init(name: "Chocolate", amount: 15.50, date: "2025-04-01", category: "Food", note: "1 bar")
    }
    static var sample6: DatabaseExpense {
        .init(name: "Tea", amount: 8.50, date: "2025-04-02", category: "Food", note: "1 cup")
    }
    static var sample7: DatabaseExpense {
        .init(name: "Soap", amount: 4.50, date: "2024-12-28", category: "Personal Care", note: "1 bar")
    }
    static var sample8: DatabaseExpense {
        .init(name: "Shampoo", amount: 7.50, date: "2024-12-29", category: "Personal Care", note: "1 bottle")
    }
}
