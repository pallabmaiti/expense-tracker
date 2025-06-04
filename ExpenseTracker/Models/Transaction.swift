//
//  Transaction.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 03/04/25.
//

import Foundation

/// A protocol that represents a financial transaction, such as an expense or income.
/// Conforming types must have a unique identifier, an amount, and a date.
class Transaction: Identifiable, Codable, Hashable {
    
    /// A unique identifier for the transaction.
    var id: String
    
    /// The monetary amount of the transaction.
    var amount: Double
    
    /// The date of the transaction in string format.
    ///
    /// - Format: `"yyyy-MM-dd"` (Default format).
    var date: String
    
    /// Any additional notes or remarks about the transaction.
    var note: String
    
    init(id: String, amount: Double, date: String, note: String) {
        self.id = id
        self.amount = amount
        self.date = date
        self.note = note
    }
    
    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(amount)
        hasher.combine(date)
        hasher.combine(note)
    }
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
