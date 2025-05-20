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
        databaseManager = DatabaseManager(localDatabaseHandler: DatabaseHandler(database: database))
    }
    
    @Test("Fetch empty expenses", .tags(.expense.fetch))
    func fetchExpenses() async throws {
        let expenses = try await databaseManager.fetchExpenses()
        #expect(expenses.isEmpty)
    }
    
    @Test("Fetch saved expenses", .tags(.expense.add, .expense.fetch))
    func fetchSavedExpenses() async throws {
        _ = try await databaseManager.saveExpense(id: UUID().uuidString, name: "Test Expense", amount: 100.0, date: Date().formattedString(), category: ExpenseTracker.Category.other.rawValue, note: "Test Note")
        let expenses = try await databaseManager.fetchExpenses()
        
        #expect(expenses.count == 1)
        let expense = try #require(expenses.first)
        #expect(expense.name == "Test Expense")
        #expect(expense.amount == 100.0)
        
        #expect(expense.date == Date().formattedString())
        #expect(expense.category == .other)
        #expect(expense.note == "Test Note")
    }
    
    @Test("Update expense", .tags(.expense.add, .expense.fetch, .expense.update))
    func updateExpense() async throws {
        _ = try await databaseManager.saveExpense(id: UUID().uuidString, name: "Test Expense", amount: 100.0, date: Date().formattedString(), category: ExpenseTracker.Category.other.rawValue, note: "Test Note")
        let expenses = try await databaseManager.fetchExpenses()
        
        #expect(expenses.count == 1)
        let expense = try #require(expenses.first)
        let status = try await databaseManager.updateExpense(id: expense.id, name: "Updated Test Expense", amount: 200.0, date: Date().byAdding(.day, value: -1).formattedString(), category: ExpenseTracker.Category.food.rawValue, note: "Updated Test Note")
        #expect(status)
    }
    
    @Test("Delete expense", .tags(.expense.add, .expense.fetch, .expense.delete))
    func deleteExpense() async throws {
        _ = try await databaseManager.saveExpense(id: UUID().uuidString, name: "Test Expense", amount: 100.0, date: Date().formattedString(), category: ExpenseTracker.Category.other.rawValue, note: "Test Note")
        let expenses = try await databaseManager.fetchExpenses()
        
        #expect(expenses.count == 1)
        let expense = try #require(expenses.first)
        let status = try await databaseManager.deleteExpense(id: expense.id)
        #expect(status)
    }
    
    @Test("Clear all expenses", .tags(.expense.add, .expense.fetch, .expense.delete))
    func clearAllExpenses() async throws {
        _ = try await databaseManager.saveExpense(id: UUID().uuidString, name: "Test Expense", amount: 100.0, date: Date().formattedString(), category: ExpenseTracker.Category.other.rawValue, note: "Test Note")
        let expenses = try await databaseManager.fetchExpenses()
        
        #expect(expenses.count == 1)
        let status = try await databaseManager.deleteAllExpenses()
        #expect(status)
    }
    
    @Test("Fetch empty incomes", .tags(.expense.fetch))
    func fetchIncomes() async throws {
        let incomes = try await databaseManager.fetchIncomes()
        #expect(incomes.isEmpty)
    }
    
    @Test("Fetch saved incomes", .tags(.income.add, .income.fetch))
    func fetchSavedIncomes() async throws {
        _ = try await databaseManager.saveIncome(id: UUID().uuidString, amount: 100.0, date: Date().formattedString(), source: ExpenseTracker.Source.salary.rawValue)
        let incomes = try await databaseManager.fetchIncomes()
        
        #expect(incomes.count == 1)
        
        let income = try #require(incomes.first)
        #expect(income.amount == 100.0)
        #expect(income.date == Date().formattedString())
        #expect(income.source == .salary)
    }
    
    @Test("Update income", .tags(.income.add, .income.fetch, .income.update))
    func updateIncome() async throws {
        _ = try await databaseManager.saveIncome(id: UUID().uuidString, amount: 100.0, date: Date().formattedString(), source: ExpenseTracker.Source.salary.rawValue)
        let incomes = try await databaseManager.fetchIncomes()
        
        #expect(incomes.count == 1)
        
        let income = try #require(incomes.first)
        let status = try await databaseManager.updateIncome(id: income.id, amount: 200.0, date: Date().byAdding(.day, value: -1).formattedString(), source: ExpenseTracker.Source.business.rawValue)
        #expect(status)
    }
    
    @Test("Delete income", .tags(.income.add, .income.fetch, .income.delete))
    func deleteIncome() async throws {
        _ = try await databaseManager.saveIncome(id: UUID().uuidString, amount: 100.0, date: Date().formattedString(), source: ExpenseTracker.Source.salary.rawValue)
        let incomes = try await databaseManager.fetchIncomes()
        
        #expect(incomes.count == 1)
        
        let income = try #require(incomes.first)
        let status = try await databaseManager.deleteIncome(id: income.id)
        #expect(status)
    }
    
    @Test("Clear all incomes", .tags(.income.add, .income.fetch, .income.delete))
    func clearAllIncomes() async throws {
        _ = try await databaseManager.saveIncome(id: UUID().uuidString, amount: 100.0, date: Date().formattedString(), source: ExpenseTracker.Source.salary.rawValue)
        let incomes = try await databaseManager.fetchIncomes()
        
        #expect(incomes.count == 1)
        let status = try await databaseManager.deleteAllIncomes()
        #expect(status)
    }
}
