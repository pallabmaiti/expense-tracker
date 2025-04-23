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
    
    @Test("Update expense", .tags(.expense.add, .expense.fetch, .expense.update))
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
    
    @Test("Delete expense", .tags(.expense.add, .expense.fetch, .expense.delete))
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
                                            Issue.record("Failed to delete expense")
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
    
    @Test("Clear all expenses", .tags(.expense.add, .expense.fetch, .expense.delete))
    func clearAllExpenses() async throws {
        await confirmation("Delete Expense") { expenseDeleted in
            databaseManager.saveExpense(name: "Test Expense", amount: 100.0, date: Date().formattedString(), category: ExpenseTracker.Category.other.rawValue, note: "Test Note") { result in
                if case .success = result {
                    self.databaseManager.fetchExpenses { result in
                        if case let .success(expenses) = result {
                            #expect(expenses.count == 1)
                            self.databaseManager.deleteAllExpenses { result in
                                if case let .success(status) = result {
                                    if status {
                                        expenseDeleted()
                                    } else {
                                        Issue.record("Failed to delete all expenses")
                                    }
                                } else {
                                    Issue.record("Failed to delete all expenses")
                                }
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
    
    @Test("Fetch empty incomes", .tags(.expense.fetch))
    func fetchIncomes() async throws {
        await confirmation("Fetch Incomes") { expensesFetched in
            databaseManager.fetchIncomes { result in
                if case let .success(incomes) = result {
                    #expect(incomes.isEmpty)
                    expensesFetched()
                } else {
                    Issue.record("Unexpected error occurred while fetching incomes")
                }
            }
        }
    }
    
    @Test("Fetch saved incomes", .tags(.income.add, .income.fetch))
    func fetchSavedIncomes() async throws {
        await confirmation("Fetch Saved Income") { incomeFetched in
            databaseManager.saveIncome(amount: 100.0, date: Date().formattedString(), source: ExpenseTracker.Source.salary.rawValue) { result in
                if case .success = result {
                    self.databaseManager.fetchIncomes { result in
                        if case let .success(incomes) = result {
                            #expect(incomes.count == 1)
                            do {
                                let income = try #require(incomes.first)
                                #expect(income.amount == 100.0)
                                #expect(income.date == Date().formattedString())
                                #expect(income.source == .salary)
                                
                                incomeFetched()
                            } catch {
                                Issue.record("Error while accessing the first income")
                            }
                            
                        } else {
                            Issue.record("Failed to fetch incomes")
                        }
                    }
                } else {
                    Issue.record("Failed to save income")
                }
            }
        }
    }
    
    @Test("Update income", .tags(.income.add, .income.fetch, .income.update))
    func updateIncome() async throws {
        await confirmation("Update Income") { incomeUpdated in
            databaseManager.saveIncome(amount: 100.0, date: Date().formattedString(), source: ExpenseTracker.Source.salary.rawValue) { result in
                if case .success = result {
                    self.databaseManager.fetchIncomes { result in
                        if case let .success(incomes) = result {
                            #expect(incomes.count == 1)
                            do {
                                let income = try #require(incomes.first)
                                self.databaseManager.updateIncome(id: income.id, amount: 200.0, date: Date().byAdding(.day, value: -1).formattedString(), source: ExpenseTracker.Source.business.rawValue) { result in
                                    if case let .success(status) = result {
                                        if status {
                                            incomeUpdated()
                                        } else {
                                            Issue.record("Failed to update income")
                                        }
                                    } else {
                                        Issue.record("Failed to update income")
                                    }
                                }
                            } catch {
                                Issue.record("Error while accessing the first income")
                            }
                            
                        } else {
                            Issue.record("Failed to fetch incomes")
                        }
                    }
                } else {
                    Issue.record("Failed to save income")
                }
            }
        }
    }
    
    @Test("Delete income", .tags(.income.add, .income.fetch, .income.delete))
    func deleteIncome() async throws {
        await confirmation("Delete Income") { incomeDeleted in
            databaseManager.saveIncome(amount: 100.0, date: Date().formattedString(), source: ExpenseTracker.Source.salary.rawValue) { result in
                if case .success = result {
                    self.databaseManager.fetchIncomes { result in
                        if case let .success(incomes) = result {
                            #expect(incomes.count == 1)
                            do {
                                let income = try #require(incomes.first)
                                self.databaseManager.deleteIncome(id: income.id) { result in
                                    if case let .success(status) = result {
                                        if status {
                                            incomeDeleted()
                                        } else {
                                            Issue.record("Failed to delete income")
                                        }
                                    } else {
                                        Issue.record("Failed to delete income")
                                    }
                                }
                            } catch {
                                Issue.record("Error while accessing the first income")
                            }
                            
                        } else {
                            Issue.record("Failed to fetch incomes")
                        }
                    }
                } else {
                    Issue.record("Failed to save income")
                }
            }
        }
    }
    
    @Test("Clear all incomes", .tags(.income.add, .income.fetch, .income.delete))
    func clearAllIncomes() async throws {
        await confirmation("Delete Income") { incomeDeleted in
            databaseManager.saveIncome(amount: 100.0, date: Date().formattedString(), source: ExpenseTracker.Source.salary.rawValue) { result in
                if case .success = result {
                    self.databaseManager.fetchIncomes { result in
                        if case let .success(incomes) = result {
                            #expect(incomes.count == 1)
                            self.databaseManager.deleteAllIncomes { result in
                                if case let .success(status) = result {
                                    if status {
                                        incomeDeleted()
                                    } else {
                                        Issue.record("Failed to delete all incomes")
                                    }
                                } else {
                                    Issue.record("Failed to delete all incomes")
                                }
                            }
                        } else {
                            Issue.record("Failed to fetch incomes")
                        }
                    }
                } else {
                    Issue.record("Failed to save income")
                }
            }
        }
    }
}
