//
//  TransactionsView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 02/04/25.
//

import SwiftUI

/// A reusable view that displays a set of filter options in a horizontally scrollable list.
/// Tapping a filter will toggle its selection and trigger a callback to display relevant UI.
struct FilterView: View {
    /// A binding to the set of currently selected filter options.
    @Binding var selectedFilterOptions: Set<FilterOption>
    
    /// A callback executed when a filter option is selected or deselected.
    var onSelectFilterOption: ((FilterOption) -> Void)
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(FilterOption.allCases, id: \.self) { filterOption in
                    Button {
                        // Toggle filter option selection.
                        if selectedFilterOptions.contains(filterOption) {
                            selectedFilterOptions.remove(filterOption)
                        } else {
                            onSelectFilterOption(filterOption)
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Text(filterOption.rawValue)
                            if selectedFilterOptions.contains(filterOption) {
                                Image(systemName: "xmark.circle.fill")
                            }
                        }
                    }
                    .tint(selectedFilterOptions.contains(filterOption) ? .primary.opacity(0.8) : .gray)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .background(selectedFilterOptions.contains(filterOption) ? .green1.opacity(0.3) : .primary.opacity(0.1))
                    .clipShape(.capsule)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 5)
        }
    }
}

/// A view that represents the header for a section of transactions grouped by month and year.
/// Displays the year, month, and total expense for the period.
struct TransactionListSectionHeaderView: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let transactions: [any Transaction]
    
    var body: some View {
        HStack {
            let components = title.components(separatedBy: " ")
            let month = components.first ?? ""
            let year = components.last ?? ""
            VStack(alignment: .leading) {
                Text("\(year)")
                    .font(.subheadline)
                
                Text("\(month)")
                    .font(.title2)
            }
            Spacer()
            Text("\(transactions.totalExpense, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                .font(.title2)
        }
        .foregroundStyle(colorScheme == .dark ? .white : .black)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.primary.opacity(0.1))
    }
}

/// A polymorphic view that displays either an expense or income item
/// based on the type of the given transaction.
struct TransactionItemView: View {
    let transaction: any Transaction
    
    var body: some View {
        if let expense = transaction as? Expense {
            ExpenseItemView(expense: expense)
        } else if let income = transaction as? Income {
            IncomeItemView(income: income)
        } else {
            Text("Unknown Transaction Type")
                .foregroundStyle(.red)
                .font(.footnote)
        }
    }
}

/// A view that displays and manages all transaction records, with support for filtering, editing, and deleting.
struct TransactionsView: View {
    
    /// ViewModel that manages the state and logic for transactions.
    @State private var viewModel: ViewModel
    
    /// Initializes the TransactionsView with a provided database manager.
    init(databaseManager: DatabaseManager) {
        _viewModel = .init(initialValue: .init(databaseManager: databaseManager))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                /// Filter options view allowing users to select filters.
                FilterView(selectedFilterOptions: $viewModel.selectedFilterOptions) { filterOption in
                    switch filterOption {
                    case .date:
                        viewModel.presentedSheet = .showDateFilter
                    case .source:
                        viewModel.presentedSheet = .showIncomeSource
                    case .category:
                        viewModel.presentedSheet = .showExpenseCategory
                    case .amount:
                        viewModel.presentedSheet = .showAmountRange
                    }
                }
                
                /// List displaying grouped transactions by month and year.
                List {
                    ForEach(viewModel.sectionKeys, id: \.self) { key in
                        let transactions = viewModel.groupedTransactionList[key]!
                        
                        // Section header
                        TransactionListSectionHeaderView(title: key, transactions: transactions)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                        
                        /// Display each transaction, with swipe actions for editing and deleting.
                        ForEach(transactions, id: \.id) { transaction in
                            TransactionItemView(transaction: transaction)
                                .swipeActions {
                                    Button("Delete", systemImage: "trash") {
                                        if let expense = transaction as? Expense {
                                            viewModel.alertType = .deleteExpense(expense)
                                        } else if let income = transaction as? Income {
                                            viewModel.alertType = .deleteIncome(income)
                                        }
                                    }
                                    .tint(.red1)
                                    
                                    Button("Edit", systemImage: "pencil") {
                                        if let expense = transaction as? Expense {
                                            viewModel.presentedSheet = .editExpense(viewModel.databaseManager, expense)
                                        } else if let income = transaction as? Income {
                                            viewModel.presentedSheet = .editIncome(viewModel.databaseManager, income)
                                        }
                                    }
                                    .tint(.green1)
                                }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .searchable(text: $viewModel.searchText, prompt: "Search for a transaction")
            .navigationTitle("Transactions")
            .toolbarSyncButton() {
                Task {
                    await viewModel.fetchExpenses()
                    await viewModel.fetchIncomes()
                }
            }
            .task {
                /// On view load, clear existing data and fetch transactions from database.
                Task {
                    viewModel.clearAllTransactions()
                    await viewModel.fetchExpenses()
                    await viewModel.fetchIncomes()
                }
            }
            .sheetPresenter(
                presentedSheet: $viewModel.presentedSheet,
                onExpenseUpdate: {
                    Task {
                        viewModel.clearAllTransactions()
                        await viewModel.fetchExpenses()
                        await viewModel.fetchIncomes()
                    }
                },
                onIncomeUpdate: {
                    Task {
                        viewModel.clearAllTransactions()
                        await viewModel.fetchExpenses()
                        await viewModel.fetchIncomes()
                    }
                },
                onExpenseCategorySelection: { selectedCategories in
                    viewModel.selectedCategories = selectedCategories
                    viewModel.selectedFilterOptions.insert(.category)
                },
                onIncomeSourceSelection: { selectedSources in
                    viewModel.selectedSources = selectedSources
                    viewModel.selectedFilterOptions.insert(.source)
                },
                onAmountRangeSelection: { selectedAmountRanges in
                    viewModel.selectedAmountRanges = selectedAmountRanges
                    viewModel.selectedFilterOptions.insert(.amount)
                },
                onDateFilterSelection: { startDate, endDate in
                    viewModel.startDate = startDate
                    viewModel.endDate = endDate
                    viewModel.selectedFilterOptions.insert(.date)
                }
            )
            .alertPresenter(
                alertType: $viewModel.alertType,
                onDeleteExpense: { expense in
                    Task { await viewModel.deleteExpense(expense) }
                },
                onDeleteIncome: { income in
                    Task { await viewModel.deleteIncome(income) }
                }
            )
        }
    }
}

#Preview {
    TransactionsView(databaseManager: .initWithInMemory)
        .environment(DatabaseManager.initWithInMemory)
        .environment(\.authenticator, FirebaseAuthenticator())
        .environment(NotificationManager(center: .init(), settings: NotificationSettingsHandler()))
}
