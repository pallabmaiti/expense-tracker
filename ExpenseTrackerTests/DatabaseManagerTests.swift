//
//  DatabaseManagerTests.swift
//  ExpenseTrackerTests
//
//  Created by Pallab Maiti on 17/04/25.
//

import Foundation
import Testing

@testable import ExpenseTracker

@Suite("DatabaseManager Tests")
struct DatabaseManagerTests {
    var databaseManager: DatabaseManager
    
    init () async throws {
        clearUserDefaults()
        let database = UserDefaultsDatabase(suiteName: userDefaultsTestSuiteName)
        databaseManager = DatabaseManager(databaseHandler: DatabaseHandlerImpl(database: database))
    }
    
    @Test("Fetch empty expenses", .tags(.expense.fetch))
    func fetchExpenses() async throws {
        await confirmation("Fetch Expenses") { expensesFetched in
            databaseManager.fetchExpenses { result in
                if case let .success(expenses) = result {
                    #expect(expenses.isEmpty)
                    expensesFetched()
                } else {
                    Issue.record("Unexpected error occurred while fetching expenses")
                }
            }
        }
    }
    
    @Test("Fetch saved expenses", .tags(.expense.add, .expense.fetch))
    func fetchSavedExpenses() async throws {
        await confirmation("Fetch Saved Expense") { expenseFetched in
            databaseManager.saveExpense(name: "Test Expense", amount: 100.0, date: Date().formattedString(), category: ExpenseTracker.Category.other.rawValue, note: "Test Note") { result in
                if case .success = result {
                    self.databaseManager.fetchExpenses { result in
                        if case let .success(expenses) = result {
                            #expect(expenses.count == 1)
                            do {
                                let expense = try #require(expenses.first)
                                #expect(expense.name == "Test Expense")
                                #expect(expense.amount == 100.0)
                                
                                #expect(expense.date == Date().formattedString())
                                #expect(expense.category == .other)
                                #expect(expense.note == "Test Note")
                                
                                expenseFetched()
                            } catch {
                                Issue.record("Error while accessing the first expense")
                            }
                            
                        } else {
                            Issue.record("Failed to fetch expenses")
                        }
                    }
                } else {
                    Issue.record("Failed to save expense")
                }
            }
        }
    }
    
    @Test("Update expense")
    func updateExpense() async throws {
        await confirmation("Update Expense") { expenseUpdated in
            databaseManager.saveExpense(name: "Test Expense", amount: 100.0, date: Date().formattedString(), category: ExpenseTracker.Category.other.rawValue, note: "Test Note") { result in
                if case .success = result {
                    self.databaseManager.fetchExpenses { result in
                        if case let .success(expenses) = result {
                            #expect(expenses.count == 1)
                            do {
                                let expense = try #require(expenses.first)
                                self.databaseManager.updateExpense(id: expense.id, name: "Updated Test Expense", amount: 200.0, date: Date().byAdding(.day, value: -1).formattedString(), category: ExpenseTracker.Category.food.rawValue, note: "Updated Test Note") { result in
                                    if case let .success(status) = result {
                                        if status {
                                            expenseUpdated()
                                        } else {
                                            Issue.record("Failed to update expense")
                                        }
                                    } else {
                                        Issue.record("Failed to update expense")
                                    }
                                }
                            } catch {
                                Issue.record("Error while accessing the first expense")
                            }
                            
                        } else {
                            Issue.record("Failed to fetch expenses")
                        }
                    }
                } else {
                    Issue.record("Failed to save expense")
                }
            }
        }
    }
    
    @Test("Delete expense")
    func deleteExpense() async throws {
        await confirmation("Delete Expense") { expenseDeleted in
            databaseManager.saveExpense(name: "Test Expense", amount: 100.0, date: Date().formattedString(), category: ExpenseTracker.Category.other.rawValue, note: "Test Note") { result in
                if case .success = result {
                    self.databaseManager.fetchExpenses { result in
                        if case let .success(expenses) = result {
                            #expect(expenses.count == 1)
                            do {
                                let expense = try #require(expenses.first)
                                self.databaseManager.deleteExpense(id: expense.id) { result in
                                    if case let .success(status) = result {
                                        if status {
                                            expenseDeleted()
                                        } else {
                                            Issue.record("Failed to update expense")
                                        }
                                    } else {
                                        Issue.record("Failed to delete expense")
                                    }
                                }
                            } catch {
                                Issue.record("Error while accessing the first expense")
                            }
                            
                        } else {
                            Issue.record("Failed to fetch expenses")
                        }
                    }
                } else {
                    Issue.record("Failed to save expense")
                }
            }
        }
    }
    
}
