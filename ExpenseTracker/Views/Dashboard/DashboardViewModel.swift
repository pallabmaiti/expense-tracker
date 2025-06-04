//
//  DashboardViewModel.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 02/04/25.
//

import Foundation

extension DashboardView {
    @Observable
    class ViewModel {
        // MARK: - Public Properties
        
        /// The list of expenses.
        private(set) var expenseList: [Expense] = []
        
        /// The list of incomes.
        private(set) var incomeList: [Income] = []
        
        /// An array holding month-year strings used for display or selection (e.g., "May 2025").
        /// Initialized with the current month and year.
        var monthYears: [String] = [Date().formattedString(dateFormat: "MMMM yyyy")]

        /// Tracks the index of the currently selected month-year from the `monthYears` array.
        /// Defaults to `0`, meaning the first (and currently only) item is selected.
        var selectedMonthYear: Int = 0

        /// The current sorting option applied to the expenses.
        var sortingOption: SortingOption = .date
        
        /// The current ordering applied to sort the expenses.
        var isDescending: Bool = true
        
        /// A variable to control the visibility of the Add Expense sheet.
        var showAddExpense: Bool = false
        
        /// A variable to control the visibility of the Add Income sheet.
        var showAddIncome: Bool = false
        
        /// A variable to control the visibility of the delete confirmation alert for an expense.
        var showExpenseDeleteConfirmation: Bool = false
        
        /// A variable to control the visibility of the delete confirmation alert for an income.
        var showIncomeDeleteConfirmation: Bool = false
        
        /// A variable to control the visibility of error messages.
        var showError: Bool = false
        
        /// The expense that the user wants to delete.
        var expenseToDelete: Expense?
        
        /// The expense that the user wants to update.
        var expenseToUpdate: Expense?
        
        /// The income that the user wants to delete.
        var incomeToDelete: Income?
        
        /// The income that the user wants to update.
        var incomeToUpdate: Income?
        
        /// A variable that holds the error message to be displayed.
        var errorMessage: String = ""
        
        // MARK: - Private Properties
        
        /// The database manager that handles the database operations.
        private let databaseManager: DatabaseManager
        
        /// Initializes the ViewModel with a given database manager.
        init(databaseManager: DatabaseManager) {
            self.databaseManager = databaseManager
        }
        
        // MARK: - Public Methods
        
        /// Fetches the expenses from the database.
        func fetchExpenses() async {
            do {
                let expenses = try await databaseManager.fetchExpenses()
                let filteredExpenses = expenses.filterByMonth(monthYears[selectedMonthYear])
                expenseList = filteredExpenses.sorted(by: .date, isDescending: true)
            } catch {
                showError = true
                errorMessage = error.localizedDescription
            }
        }
        
        /// Fetches the incomes from the database.
        func fetchIncomes() async {
            do {
                let incomes = try await databaseManager.fetchIncomes()
                let filteredIncomes = incomes.filterByMonth(monthYears[selectedMonthYear])
                incomeList = filteredIncomes.sorted(by: .date, isDescending: true)
            } catch {
                showError = true
                errorMessage = error.localizedDescription
            }
        }
        
        func prepareMonthYearSelection() async {
            do {
                let expenses = try await databaseManager.fetchExpenses()
                let monthYearSet = Set(expenses.map({ $0.formattedDate.formattedString(dateFormat: "MMMM yyyy") }))
                
                guard monthYearSet.isNotEmpty else { return }
                
                monthYears = monthYearSet.sorted { dateA, dateB in
                    return dateA.toDate(dateFormat: "MMMM yyyy") < dateB.toDate(dateFormat: "MMMM yyyy")
                }
                                
                selectedMonthYear = monthYears.count - 1
            } catch {
                print("Error preparing month year selection: \(error.localizedDescription)")
            }
        }
        
        /// Deletes an expense by its identifier.
        /// - Parameters:
        ///   - id: The identifier of the expense to be deleted.
        func deleteExpense(_ expense: Expense) async {
            do {
                _ = try await databaseManager.deleteExpense(expense)
                await fetchExpenses()
            } catch {
                showError = true
                errorMessage = error.localizedDescription
            }
        }
        
        /// Deletes an income by its identifier.
        /// - Parameters:
        ///   - id: The identifier of the income to be deleted.
        func deleteIncome(_ income: Income) async {
            do {
                _ = try await databaseManager.deleteIncome(income)
                await fetchIncomes()
            } catch {
                showError = true
                errorMessage = error.localizedDescription
            }
        }
        
        /// Sort incomes by `SortingOption`.
        func sortExpenses() {
            expenseList = expenseList.sorted(by: sortingOption, isDescending: isDescending)
        }
    }
}
