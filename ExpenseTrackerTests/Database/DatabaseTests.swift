//
//  DatabaseTests.swift
//  ExpenseTrackerTests
//
//  Created by Pallab Maiti on 16/04/25.
//

import Foundation
import Testing

@testable import ExpenseTracker

@Suite("Database Tests")
struct DatabaseTests {

    var database: Database
    var newExpense: DatabaseExpense
    var newIncome: DatabaseIncome
    
    init() async throws {
        clearUserDefaults()
        
        database = UserDefaultsDatabase(suiteName: userDefaultsTestSuiteName)
        
        newExpense = newTestDatabaseExpense()
        newIncome = newTestDatabaseIncome()
    }
    
    @Test("Add Expense", .tags(.expense.add))
    func addExpense() async throws {
        try await database.addExpense(newExpense)
        let expenses = try await database.fetchExpenses()
        
        #expect(expenses.count == 1)
        #expect(expenses[0].id == newExpense.id)
    }

    @Test("Update Expense", .tags(.expense.update))
    func updateExpense() async throws {
        try await database.addExpense(newExpense)
        
        let newDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let updatedExpense = newTestDatabaseExpense(id: newExpense.id, name: "Updated Expense", amount: 200.0, date: newDate, category: .entertainment, note: "Updated Note")
        
        try await database.updateExpense(for: newExpense.id, with: updatedExpense)
        
        let expenses = try await database.fetchExpenses()
        
        #expect(expenses.count == 1)
        #expect(expenses[0].id == updatedExpense.id)
        #expect(expenses[0].name == updatedExpense.name)
        #expect(expenses[0].amount == updatedExpense.amount)
        #expect(expenses[0].date == updatedExpense.date)
        #expect(expenses[0].category == updatedExpense.category)
        #expect(expenses[0].note == updatedExpense.note)
    }
    
    @Test("Delete Expense", .tags(.expense.delete))
    func deleteExpense() async throws {
        try await database.addExpense(newExpense)
        
        var expenses = try await database.fetchExpenses()
        
        #expect(expenses.count == 1)
        
        try await database.deleteExpense(newExpense.id)
        
        expenses = try await database.fetchExpenses()
        
        #expect(expenses.count == 0)
    }
    
    @Test("Clear Expenses", .tags(.expense.delete))
    func clearExpenses() async throws {
        database.addExpense(newExpense)
        database.addExpense(newTestDatabaseExpense())
        
        #expect(expenses.count == 2)
        
        database.clearExpenses()
        
        #expect(expenses.count == 0)
    }
    
    @Test("Add Income", .tags(.income.add))
    func addIncome() async throws {
        database.addIncome(newIncome)
        
        #expect(database.incomes.count == 1)
    }
    
    @Test("Update Income", .tags(.income.update))
    func updateIncome() async throws {
        database.addIncome(newIncome)
        
        let newDate = Date().byAdding(.day, value: -1)
        let updatedIncome = newTestDatabaseIncome(id: newIncome.id, amount: 20000.0, date: newDate, source: .business)
        
        database.updateIncome(for: newIncome.id, with: updatedIncome)
        
        #expect(database.incomes.count == 1)
        #expect(database.incomes[0].id == updatedIncome.id)
        #expect(database.incomes[0].source == updatedIncome.source)
        #expect(database.incomes[0].date == updatedIncome.date)
        #expect(database.incomes[0].amount == updatedIncome.amount)
    }
    
    @Test("Delete Income", .tags(.income.delete))
    func deleteIncome() async throws {
        database.addIncome(newIncome)
        
        #expect(database.incomes.count == 1)
        
        database.deleteIncome(newIncome.id)
        
        #expect(database.incomes.count == 0)
    }
    
    @Test("Clear Incomes", .tags(.income.delete))
    func clearIncomes() async throws {
        database.addIncome(newIncome)
        database.addIncome(newTestDatabaseIncome())
        
        #expect(database.incomes.count == 2)
        
        database.clearIncomes()
        
        #expect(database.incomes.count == 0)
    }
    
    @Test("Thread Safety")
    func threadSafety() async throws {
        await confirmation(
            "Thread safety",
            expectedCount: 100
        ) { addExpense in
            for i in 0..<100 {
                DispatchQueue.global().async {
                    let expense = newTestDatabaseExpense(id: "\(i)", name: "Expense \(i)", amount: Double(i), date: Date(), category: ExpenseTracker.Category.allCases[i % ExpenseTracker.Category.allCases.count], note: "Note \(i)")
                    
                    database.addExpense(expense)
                    
                    let income = newTestDatabaseIncome(id: "\(i)", amount: Double(i), date: Date(), source: ExpenseTracker.Source.allCases[i % ExpenseTracker.Source.allCases.count])
                    
                    database.addIncome(income)
                    addExpense()
                }
            }
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }
    }
}
