//
//  ExpenseViewModel.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 27/03/25.
//

import Foundation
import Observation

/// The `SortingOption` enum defines various sorting options for sorting expenses by date or amount.
/// It conforms to `String` and `CaseIterable` to be used in UI elements like `Picker`.
enum SortingOption: String, CaseIterable {
    
    /// Sort by date in descending order (newest first).
    case dateDescending = "Date: New - Old"
    
    /// Sort by date in ascending order (oldest first).
    case dateAscending = "Date: Old - New"
    
    /// Sort by amount in descending order (highest first).
    case amountDescending = "Amount: High - Low"
    
    /// Sort by amount in ascending order (lowest first).
    case amountAscending = "Amount: Low - High"
    
    /// Provides a user-friendly title for the sorting option.
    var title: String {
        switch self {
        case .dateDescending:
            return "Newest"
        case .dateAscending:
            return "Oldest"
        case .amountDescending:
            return "Highest"
        case .amountAscending:
            return "Lowest"
        }
    }
}

/// `ViewModel`an observable class that acts as the data source and logic handler for the ExpenseListView. It interacts with the DatabaseQueryType (i.e., a database manager) to fetch, delete, and sort expenses.

extension ExpenseListView {
    
    @Observable
    class ViewModel {
        /// The list of expenses for each year.
        private(set) var expenseDataList: [ExpenseData] = []
        
        /// Closure that is triggered when an expense is deleted.
        var expenseDeleted: () -> Void = { }
        
        /// Closure to handle errors and provide error messages.
        var errorOccured: (String) -> Void = { _ in }
        
        /// The current sorting option applied to the expenses.
        var sortingOption: SortingOption = .dateDescending
        
        /// The database manager that handles the database operations.
        let databaseManager: DatabaseQueryType
        
        /// Initializes the ViewModel with a given database manager.
        init(databaseManager: DatabaseQueryType) {
            self.databaseManager = databaseManager
        }
        
        /// Fetches the expenses from the database.
        /// - Parameter completion: A closure to be executed upon completion, with a result indicating success or failure.
        func fetchExpenses(_ completion: @escaping (Result<Bool, Error>) -> Void) {
            databaseManager.fetchExpenses { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let expenses):
                    expenseDataList = expenses
                    updateSorting()
                    completion(.success(true))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        /// Deletes an expense by its identifier.
        /// - Parameters:
        ///   - id: The identifier of the expense to be deleted.
        ///   - completion: A closure that returns the result of the delete operation.
        func deleteExpense(id: String, completion: @escaping (Result<Bool, Error>) -> Void) {
            databaseManager.deleteExpense(id: id, completion: completion)
        }
        
        /// Updates the sorting order of the expenses.
        func updateSorting() {
            var updatedExpenseDataList: [ExpenseData] = []
            for expenseData in expenseDataList {
                let updatedExpenses: ExpenseData.Expenses = .init(
                    january: expenseData.expenses.january.sort(by: sortingOption),
                    february: expenseData.expenses.february.sort(by: sortingOption),
                    march: expenseData.expenses.march.sort(by: sortingOption),
                    april: expenseData.expenses.april.sort(by: sortingOption),
                    may: expenseData.expenses.may.sort(by: sortingOption),
                    june: expenseData.expenses.june.sort(by: sortingOption),
                    july: expenseData.expenses.july.sort(by: sortingOption),
                    august: expenseData.expenses.august.sort(by: sortingOption),
                    september: expenseData.expenses.september.sort(by: sortingOption),
                    october: expenseData.expenses.october.sort(by: sortingOption),
                    november: expenseData.expenses.november.sort(by: sortingOption),
                    december: expenseData.expenses.december.sort(by: sortingOption)
                )
                let updatedExpenseData = ExpenseData(year: expenseData.year, expenses: updatedExpenses)
                updatedExpenseDataList.append(updatedExpenseData)
            }
            expenseDataList = updatedExpenseDataList
        }
    }
}

/// An extension for the `Expense` array, adding a `sort(by:)` method to sort expenses based on the selected sorting option.
extension [Expense] {
    
    /// Sorts the expenses based on the given `sortingOption`.
    /// - Parameter sortingOption: The sorting option to apply (date or amount).
    /// - Returns: A sorted array of expenses based on the selected sorting option.
    func sort(by sortingOption: SortingOption) -> [Expense] {
        switch sortingOption {
        case .dateDescending:
            return self.sorted { $0.date > $1.date }
        case .dateAscending:
            return self.sorted { $0.date < $1.date }
        case .amountDescending:
            return self.sorted { $0.amount > $1.amount }
        case .amountAscending:
            return self.sorted { $0.amount < $1.amount }
        }
    }
}
