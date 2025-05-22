//
//  TestHelpers.swift
//  ExpenseTrackerTests
//
//  Created by Pallab Maiti on 16/04/25.
//

import Foundation
@testable import ExpenseTracker

let userDefaultsTestSuiteName = "ExpenseTrackerTests"

func clearUserDefaults() {
    UserDefaults.standard.removeObject(forKey: "Expenses")
    UserDefaults.standard.removeObject(forKey: "Incomes")
}

func newTestDatabaseExpense(
    id: String = UUID().uuidString,
    name: String = "Test Expense",
    amount: Double = 100.0,
    date: Date = Date(),
    category: ExpenseTracker.Category = .other,
    note: String = "Test Note"
) -> DatabaseExpense {
    .init(id: id, name: name, amount: amount, date: date.formattedString(), category: category.rawValue, note: note)
}

func newTestDatabaseIncome(
    id: String = UUID().uuidString,
    amount: Double = 10000.0,
    date: Date = Date(),
    source: ExpenseTracker.Source = .salary
) -> DatabaseIncome {
    .init(id: id, amount: amount, date: date.formattedString(), source: source.rawValue)
}

func newTestDatabaseUser(
    id: String = UUID().uuidString,
    email: String = "test@example.com",
    firstName: String = "Test",
    lastName: String = "User"
) -> DatabaseUser {
    .init(id: id, email: email, firstName: firstName, lastName: lastName)
}

func newTestExpense(
    id: String = UUID().uuidString,
    name: String = "Test Expense",
    amount: Double = 100.0,
    date: Date = Date(),
    category: ExpenseTracker.Category = .other,
    note: String = "Test Note"
) -> Expense {
    .init(id: id, name: name, amount: amount, date: date, category: category, note: note)
}

func newTestIncome(
    id: String = UUID().uuidString,
    amount: Double = 10000.0,
    date: Date = Date(),
    source: ExpenseTracker.Source = .salary
) -> Income {
    .init(id: id, amount: amount, source: source, date: date)
}

func updatedTestExpense(
    id: String,
    name: String = "Updated Test Expense",
    amount: Double = 100.0,
    date: Date = Date(),
    category: ExpenseTracker.Category = .other,
    note: String = "Updated Test Note"
) -> Expense {
    .init(id: id, name: name, amount: amount, date: date, category: category, note: note)
}

func updatedTestIncome(
    id: String,
    amount: Double = 10000.0,
    date: Date = Date(),
    source: ExpenseTracker.Source = .other
) -> Income {
    .init(id: id, amount: amount, source: source, date: date)
}

func newTestUser(
    id: String = UUID().uuidString,
    email: String? = "test@example.com",
    firstName: String? = "Test",
    lastName: String? = "User"
) -> User {
    .init(id: id, email: email, firstName: firstName, lastName: lastName)
}

func updatedTestUser(
    id: String,
    email: String? = "updated@example.com",
    firstName: String? = "Updated",
    lastName: String? = "Test User"
) -> User {
    .init(id: id, email: email, firstName: firstName, lastName: lastName)
}

extension Date {
    func byAdding(_ component: Foundation.Calendar.Component, value: Int) -> Date {
        return Foundation.Calendar.current.date(byAdding: component, value: value, to: self)!
    }
}
