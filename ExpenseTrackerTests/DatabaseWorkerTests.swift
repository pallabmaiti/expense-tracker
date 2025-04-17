//
//  DatabaseWorkerTests.swift
//  ExpenseTrackerTests
//
//  Created by Pallab Maiti on 17/04/25.
//

import Foundation
import Testing

@testable import ExpenseTracker

@Suite("Database Worker Tests")
struct DatabaseWorkerTests {
    var databaseWorker: DatabaseWorker
    
    init() async throws {
        clearUserDefaults()
        databaseWorker = DatabaseWorker(datebase: UserDefaultsDatabase(suiteName: userDefaultsTestSuiteName))
    }
    
    @Test("Return empty array when no expense saved", .tags(.expense.fetch))
    func fetchAllExpenses_whenNoExpenseSaved_returnsEmptyArray() async throws {
        let fetchedExpenses = try #require(databaseWorker.fetchExpenses()["data"] as? [[String: Any]])
        #expect(fetchedExpenses.isEmpty)
    }
    
    @Test("Return expense array when expense saved", .tags(.expense.add, .expense.fetch))
    func fetchAllExpenses_whenExpenseSaved_returnsExpenseArray() async throws {
        _ = databaseWorker.saveExpense(name: "Test Expense", amount: 100.0, date: Date().formattedString(), category: ExpenseTracker.Category.food.rawValue, note: "Weekly grocery shopping")
        
        let fetchedExpenses = try #require(databaseWorker.fetchExpenses()["data"] as? [[String: Any]])
        
        #expect(fetchedExpenses.count == 1)
        
        let firstExpense = try #require(fetchedExpenses.first)
        #expect(firstExpense["name"] as? String == "Test Expense")
        #expect(firstExpense["amount"] as? Double == 100.0)
        #expect(firstExpense["date"] as? String == Date().formattedString())
        #expect(firstExpense["category"] as? String == ExpenseTracker.Category.food.rawValue)
        #expect(firstExpense["note"] as? String == "Weekly grocery shopping")
    }
    
    @Test("Update expense", .tags(.expense.update))
    func updateExpense() async throws {
        _ = databaseWorker.saveExpense(name: "Test Expense", amount: 100.0, date: Date().formattedString(), category: ExpenseTracker.Category.food.rawValue, note: "Weekly grocery shopping")
        
        let fetchedExpenses = try #require(databaseWorker.fetchExpenses()["data"] as? [[String: Any]])
        let firstExpense = try #require(fetchedExpenses.first)
        let expenseId = try #require(firstExpense["id"] as? String)
        _ = try databaseWorker.updateExpense(id: expenseId, name: "Updated Test Expense", amount: 200.0, date: Date().byAdding(.day, value: -1).formattedString(), category: ExpenseTracker.Category.entertainment.rawValue, note: "Updated Weekly grocery shopping")
            
        let freshFetchedExpenses = try #require(databaseWorker.fetchExpenses()["data"] as? [[String: Any]])
        let updatedFirstExpense = try #require(freshFetchedExpenses.first)
        
        #expect(updatedFirstExpense["name"] as? String == "Updated Test Expense")
        #expect(updatedFirstExpense["amount"] as? Double == 200.0)
        #expect(updatedFirstExpense["note"] as? String == "Updated Weekly grocery shopping")
        #expect(updatedFirstExpense["date"] as? String == Date().byAdding(.day, value: -1).formattedString())
        #expect(updatedFirstExpense["category"] as? String == ExpenseTracker.Category.entertainment.rawValue)
        #expect(updatedFirstExpense["id"] as? String == expenseId)
    }
    
    @Test("Update expense failure", .tags(.expense.update))
    func updateExpenseFailure() async {
        #expect(throws: ExpenseTrackerError.dataNotFound) {
            _ = try databaseWorker.updateExpense(id: "some-id", name: "Updated Test Expense", amount: 200.0, date: Date().byAdding(.day, value: -1).formattedString(), category: ExpenseTracker.Category.entertainment.rawValue, note: "Updated Weekly grocery shopping")
        }
    }
    
    @Test("Delete expense", .tags(.expense.delete))
    func deleteExpense() async throws {
        _ = databaseWorker.saveExpense(name: "Test Expense", amount: 100.0, date: Date().formattedString(), category: ExpenseTracker.Category.food.rawValue, note: "Weekly grocery shopping")
        
        let fetchedExpenses = try #require(databaseWorker.fetchExpenses()["data"] as? [[String: Any]])
        
        #expect(fetchedExpenses.count == 1)
        
        let expenseToDelete = try #require(fetchedExpenses.first)
        let expenseIdToDelete = try #require(expenseToDelete["id"] as? String)
        
        _ = try databaseWorker.deleteExpense(id: expenseIdToDelete)
        
        let freshFetchedExpenses = try #require(databaseWorker.fetchExpenses()["data"] as? [[String: Any]])

        #expect(freshFetchedExpenses.count == 0)
    }
    
    @Test("Remove all expenses", .tags(.expense.delete))
    func removeAllExpenses() async throws {
        for i in 0..<10 {
            _ = databaseWorker.saveExpense(name: "Test Expense \(i)", amount: 100.0, date: Date().formattedString(), category: ExpenseTracker.Category.food.rawValue, note: "Note \(i)")
        }
     
        let fetchedExpenses = try #require(databaseWorker.fetchExpenses()["data"] as? [[String: Any]])
        
        #expect(fetchedExpenses.count == 10)
        
        _ = databaseWorker.deleteAllExpenses()
        
        let freshFetchedExpenses = try #require(databaseWorker.fetchExpenses()["data"] as? [[String: Any]])
        
        #expect(freshFetchedExpenses.count == 0)
    }
    
    @Test("Return empty array when no income saved", .tags(.income.fetch))
    func fetchAllIncomes_whenNoIncomeSaved_returnsEmptyArray() async throws {
        let fetchedIncomes = try #require(databaseWorker.fetchIncomes()["data"] as? [[String: Any]])
        
        #expect(fetchedIncomes.isEmpty)
    }
    
    @Test("Return income array when income saved", .tags(.income.add, .income.fetch))
    func fetchAllIncomes_whenIncomeSaved_returnsExpenseArray() async throws {
        _ = databaseWorker.saveIncome(amount: 100.0, date: Date().formattedString(), source: ExpenseTracker.Source.salary.rawValue)
        
        let fetchedIncomes = try #require(databaseWorker.fetchIncomes()["data"] as? [[String: Any]])
        
        #expect(fetchedIncomes.count == 1)
        
        let firstIncome = try #require(fetchedIncomes.first)
        #expect(firstIncome["amount"] as? Double == 100.0)
        #expect(firstIncome["date"] as? String == Date().formattedString())
        #expect(firstIncome["source"] as? String == ExpenseTracker.Source.salary.rawValue)
    }
    
    @Test("Update income", .tags(.income.update))
    func updateIncome() async throws {
        _ = databaseWorker.saveIncome(amount: 100.0, date: Date().formattedString(), source: ExpenseTracker.Source.salary.rawValue)
        
        let fetchedIncomes = try #require(databaseWorker.fetchIncomes()["data"] as? [[String: Any]])
        let firstIncome = try #require(fetchedIncomes.first)
        let incomeId = try #require(firstIncome["id"] as? String)
        _ = try databaseWorker.updateIncome(id: incomeId, amount: 200.0, date: Date().byAdding(.day, value: -1).formattedString(), source: ExpenseTracker.Source.business.rawValue)
        
        let freshFetchedIncomes = try #require(databaseWorker.fetchIncomes()["data"] as? [[String: Any]])
        let updatedFirstIncome = try #require(freshFetchedIncomes.first)
        
        #expect(updatedFirstIncome["amount"] as? Double == 200.0)
        #expect(updatedFirstIncome["date"] as? String == Date().byAdding(.day, value: -1).formattedString())
        #expect(updatedFirstIncome["source"] as? String == ExpenseTracker.Source.business.rawValue)
        #expect(updatedFirstIncome["id"] as? String == incomeId)
    }
    
    @Test("Update income failure", .tags(.income.update))
    func updateIncomeFailure() async throws {
        #expect(throws: ExpenseTrackerError.dataNotFound) {
            _ = try databaseWorker.updateIncome(id: "some-id", amount: 200.0, date: Date().byAdding(.day, value: -1).formattedString(), source: ExpenseTracker.Source.business.rawValue)
        }
    }
    
    @Test("Delete income", .tags(.income.delete))
    func deleteIncome() async throws {
        _ = databaseWorker.saveIncome(amount: 100.0, date: Date().formattedString(), source: ExpenseTracker.Source.salary.rawValue)
        
        let fetchedIncomes = try #require(databaseWorker.fetchIncomes()["data"] as? [[String: Any]])
        #expect(fetchedIncomes.count == 1)
        
        let incomeToDelete = try #require(fetchedIncomes.first)
        let incomeIdToDelete = try #require(incomeToDelete["id"] as? String)
        
        _ = try databaseWorker.deleteIncome(id: incomeIdToDelete)
        
        let freshFetchedIncomes = try #require(databaseWorker.fetchIncomes()["data"] as? [[String: Any]])
        
        #expect(freshFetchedIncomes.count == 0)
    }
    
    @Test("Remove all incomes", .tags(.income.delete))
    func removeAllIncomes() async throws {
        for _ in 0..<10 {
            _ = databaseWorker.saveIncome(amount: 100.0, date: Date().formattedString(), source: ExpenseTracker.Source.salary.rawValue)
        }
        
        let fetchedIncomes = try #require(databaseWorker.fetchIncomes()["data"] as? [[String: Any]])
        
        #expect(fetchedIncomes.count == 10)
        
        _ = databaseWorker.deleteAllIncomes()
        
        let freshFetchedIncomes = try #require(databaseWorker.fetchIncomes()["data"] as? [[String: Any]])
        
        #expect(freshFetchedIncomes.count == 0)
    }
}
