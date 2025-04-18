//
//  Extensions.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 01/04/25.
//

import Foundation

/// A constant for the default date format used for formatting and parsing dates.
/// The default format is "yyyy-MM-dd".
let DATE_FORMAT: String = "yyyy-MM-dd"

/// An extension for the `Date` type that adds functionality for formatting a `Date` object into a `String`.
extension Date {
    
    /// Converts a `Date` object to a formatted string.
    ///
    /// - Parameter dateFormat: A custom date format string (default is "yyyy-MM-dd").
    /// - Returns: A string representation of the `Date` object formatted according to the specified format.
    func formattedString(dateFormat: String = DATE_FORMAT) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: self)
    }
}


/// An extension for the `String` type that adds functionality for parsing a `String` into a `Date` object.
extension String {
    
    /// Converts a `String` representation of a date to a `Date` object.
    ///
    /// - Parameter dateFormat: A custom date format string (default is "yyyy-MM-dd").
    /// - Returns: A `Date` object corresponding to the string representation.
    /// - Note: If the string cannot be parsed into a valid `Date` object, this will crash.
    func toDate(dateFormat: String = DATE_FORMAT) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: self)!
    }
}


/// An extension for the `Collection` type that adds a computed property to check if a collection is not empty.
extension Collection {
    
    /// A Boolean value that indicates whether the collection is not empty.
    ///
    /// - Returns: `true` if the collection contains at least one element; `false` otherwise.
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

extension Bundle {
    static var clerkPublishableKey: String {
        guard let key = main.infoDictionary?["CLERK_PUBLISHABLE_KEY"] as? String else {
            fatalError(#function + ": Missing CLERK_PUBLISHABLE_KEY in Secrets.xcconfig")
        }
        return key
    }
}
