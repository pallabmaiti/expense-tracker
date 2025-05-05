//
//  TransactionsViewModel.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 03/04/25.
//

import Foundation

extension TransactionsView {
    /// ViewModel for the `TransactionsView` screen.
    /// Responsible for managing transaction data, filtering logic, user interactions, and error states.
    @Observable
    class ViewModel {

        // MARK: - Filter State

        /// Stores the active filter options selected by the user (e.g., date, category, source, amount).
        var selectedFilterOptions: Set<FilterOption> = []

        /// The end date selected for filtering transactions.
        var endDate: Date = Date()

        /// The start date selected for filtering transactions.
        var startDate: Date = Date()

        /// Categories selected for filtering expense transactions.
        var selectedCategories: [Category] = []

        /// Sources selected for filtering income transactions.
        var selectedSources: [Source] = []

        /// Boolean to toggle the display of expense category filter UI.
        var showExpenseCategoryFilter: Bool = false

        /// Boolean to toggle the display of income source filter UI.
        var showIncomeSourceFilter: Bool = false

        /// Boolean to toggle the display of date range filter UI.
        var showDateFilter: Bool = false

        /// Boolean to toggle the display of amount range filter UI.
        var showAmountFilter: Bool = false

        /// Amount ranges selected for filtering transactions.
        var selectedAmountRanges: [AmountRange] = []

        // MARK: - Transaction State

        /// All transactions (both incomes and expenses) fetched from the database.
        private var allTransactions: [any Transaction] = []

        /// Grouped and filtered transactions based on user-selected filters.
        var transactions: [(key: String, value: [any Transaction])] {
            filterTransactions()
        }

        // MARK: - Error Handling

        /// Indicates if an error alert should be shown.
        var showError: Bool = false

        /// Stores a user-readable error message.
        var errorMessage: String = ""

        // MARK: - Search

        /// Search text entered by the user to filter transactions.
        var searchText: String = ""

        // MARK: - Delete & Edit Handling

        /// Whether the confirmation alert for deleting an expense should be shown.
        var showExpenseDeleteConfirmation: Bool = false

        /// Whether the confirmation alert for deleting an income should be shown.
        var showIncomeDeleteConfirmation: Bool = false

        /// Expense selected for deletion.
        var expenseToDelete: Expense?

        /// Expense selected for editing.
        var expenseToUpdate: Expense?

        /// Income selected for deletion.
        var incomeToDelete: Income?

        /// Income selected for editing.
        var incomeToUpdate: Income?

        // MARK: - Database

        /// Interface to interact with the database for querying and persisting transactions.
        let databaseManager: DatabaseManager

        /// Initializes the ViewModel with a given database manager.
        /// - Parameter databaseManager: The database interface for transactions.
        init(databaseManager: DatabaseManager) {
            self.databaseManager = databaseManager
        }

        // MARK: - Fetching Data

        /// Fetches all incomes from the database and appends them to the transaction list.
        func fetchIncomes() async {
            do {
                let incomes = try await databaseManager.fetchIncomes()
                allTransactions.append(contentsOf: incomes)
                allTransactions = allTransactions.sorted { $0.formattedDate > $1.formattedDate }
            } catch {
                showError = true
                errorMessage = error.localizedDescription
            }
            
        }
        
        /// Fetches all expenses from the database and appends them to the transaction list.
        func fetchExpenses() async {
            do {
                let expenses = try await databaseManager.fetchExpenses()
                allTransactions.append(contentsOf: expenses)
                allTransactions = allTransactions.sorted { $0.formattedDate > $1.formattedDate }
            } catch {
                showError = true
                errorMessage = error.localizedDescription
            }
        }
        
        /// Clears all transactions currently held in memory.
        func clearAllTransactions() {
            allTransactions.removeAll()
        }
        
        // MARK: - Deletion
        
        /// Deletes an expense from the database.
        /// - Parameter id: The unique ID of the expense to be deleted.
        func deleteExpense(_ id: String) async {
            do {
                _ = try await databaseManager.deleteExpense(id: id)
                await fetchExpenses()
            } catch {
                showError.toggle()
                errorMessage = error.localizedDescription
            }
            
        }
        
        /// Deletes an income from the database.
        /// - Parameter id: The unique ID of the income to be deleted.
        func deleteIncome(_ id: String) async {
            do {
                _ = try await databaseManager.deleteIncome(id: id)
                await fetchIncomes()
            } catch {
                showError.toggle()
                errorMessage = error.localizedDescription
            }
        }
        
        // MARK: - Filtering

        /// Filters the list of transactions based on selected options (date, category, source, amount, search).
        /// - Returns: Grouped and sorted transactions matching all active filters.
        private func filterTransactions() -> [(key: String, value: [any Transaction])] {
            var filteredTransactions = allTransactions

            // Filter by selected date range
            if selectedFilterOptions.contains(.date) {
                filteredTransactions = filteredTransactions.filter { transaction in
                    transaction.formattedDate >= startDate && transaction.formattedDate <= endDate
                }
            }

            // Filter by selected expense categories
            if selectedFilterOptions.contains(.category) {
                filteredTransactions = filteredTransactions.filter { transaction in
                    if let expense = transaction as? Expense {
                        return selectedCategories.contains(expense.category)
                    }
                    return true
                }
            }

            // Filter by selected income sources
            if selectedFilterOptions.contains(.source) {
                filteredTransactions = filteredTransactions.filter { transaction in
                    if let income = transaction as? Income {
                        return selectedSources.contains(income.source)
                    }
                    return true
                }
            }

            // Filter by selected amount range(s)
            if selectedFilterOptions.contains(.amount) {
                filteredTransactions = filteredTransactions.filter { transaction in
                    selectedAmountRanges.contains { $0.range.contains(abs(transaction.amount)) }
                }
            }

            // Filter by search text (case-insensitive)
            if !searchText.isEmpty {
                filteredTransactions = filteredTransactions.filter { transaction in
                    if let income = transaction as? Income {
                        return income.source.rawValue.localizedCaseInsensitiveContains(searchText)
                    } else if let expense = transaction as? Expense {
                        return expense.name.localizedCaseInsensitiveContains(searchText)
                            || expense.note.localizedCaseInsensitiveContains(searchText)
                    }
                    return false
                }
            }

            // Group filtered transactions by month-year and sort descending
            let grouped = groupTransactionsByMonthYear(filteredTransactions)
            return grouped.sorted {
                guard let d1 = monthYearFormatter.date(from: $0.key),
                      let d2 = monthYearFormatter.date(from: $1.key) else { return false }
                return d1 > d2
            }
        }
        
        // MARK: - Grouping

        /// Groups an array of transactions by the month and year of their date.
        /// - Parameter transactions: The list of transactions to group.
        /// - Returns: A dictionary where the key is a "MMMM yyyy" string and the value is the list of transactions.
        private func groupTransactionsByMonthYear(_ transactions: [any Transaction]) -> [String: [any Transaction]] {
            Dictionary(grouping: transactions) { transaction in
                monthYearFormatter.string(from: transaction.formattedDate)
            }
        }

        // MARK: - Helpers

        /// Formatter used to convert dates to "MMMM yyyy" format.
        private let monthYearFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter
        }()
    }
}

// MARK: - Array Extension

/// Extension to compute the total expense value from a list of transactions.
extension [Transaction] {
    /// Computes the total value of all expenses in the list.
    /// Ignores income transactions.
    var totalExpense: Double {
        reduce(0) { result, transaction in
            if transaction is Expense {
                return result + ((transaction as! Expense).amount)
            } else {
                return result
            }
        }
    }
}
