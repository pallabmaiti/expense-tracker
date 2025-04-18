//
//  InsightsViewModel.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 04/04/25.
//

import Foundation

extension InsightsView {
    
    /// The ViewModel for the `InsightsView`, responsible for fetching and transforming
    /// income and expense data into chart-friendly formats.
    @Observable
    class ViewModel {
        
        // MARK: - Public Properties
        
        /// A list of aggregated chart items for current month's expenses.
        private(set) var expenseList: [InsightsChartItem] = []
        
        /// A list of aggregated chart items for current month's incomes.
        private(set) var incomeList: [InsightsChartItem] = []
        
        /// The currently selected month (formatted like "April 2025").
        var currentMonth: String = Date().formattedString(dateFormat: "MMMM yyyy")
        
        /// Determines whether an error alert should be shown.
        var showError: Bool = false
        
        /// The error message to show in case of a failure.
        var errorMessage: String = ""
        
        /// Controls the presentation of the Add Expense sheet.
        var showAddExpense: Bool = false
        
        /// Controls the presentation of the Add Income sheet.
        var showAddIncome: Bool = false
        
        // MARK: - Private Properties
        
        /// The database manager responsible for fetching income and expense data.
        private let databaseManager: DatabaseQueryType
        
        // MARK: - Initialization
        
        /// Initializes the ViewModel with a given database manager.
        /// - Parameter databaseManager: The data provider for incomes and expenses.
        init(databaseManager: DatabaseQueryType) {
            self.databaseManager = databaseManager
        }
        
        // MARK: - Public Methods
        
        /// Fetches income records from the database, filters them by the current month,
        /// and groups them by `Source` to prepare chart data.
        func fetchIncomes() {
            databaseManager.fetchIncomes { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let incomes):
                    incomeList = [] // Reset list before adding fresh items
                    
                    let filteredIncomes = incomes.filter {
                        $0.formattedDate
                            .formattedString(dateFormat: "MMMM yyyy")
                            .localizedCaseInsensitiveContains(self.currentMonth)
                    }
                    
                    // Group and sum by source
                    Source.allCases.forEach { source in
                        let incomeBySource = filteredIncomes.filter { $0.source == source }
                        if !incomeBySource.isEmpty {
                            let total = incomeBySource.reduce(0) { $0 + $1.amount }
                            self.incomeList.append(.init(amount: total, source: source))
                        }
                    }
                    
                case .failure(let error):
                    showError = true
                    errorMessage = error.localizedDescription
                }
            }
        }
        
        /// Fetches expense records from the database, filters them by the current month,
        /// and groups them by `Category` to prepare chart data.
        func fetchExpenses() {
            databaseManager.fetchExpenses { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let expenses):
                    expenseList = [] // Reset list before adding fresh items
                    
                    let filteredExpenses = expenses.filter {
                        $0.formattedDate
                            .formattedString(dateFormat: "MMMM yyyy")
                            .localizedCaseInsensitiveContains(self.currentMonth)
                    }
                    
                    // Group and sum by category
                    Category.allCases.forEach { category in
                        let expenseByCategory = filteredExpenses.filter { $0.category == category }
                        if !expenseByCategory.isEmpty {
                            let total = expenseByCategory.reduce(0) { $0 + $1.amount }
                            self.expenseList.append(.init(amount: total, category: category))
                        }
                    }
                    
                case .failure(let error):
                    showError = true
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
