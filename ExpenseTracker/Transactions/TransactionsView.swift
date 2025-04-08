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

/// A view that displays and manages all transaction records, with support for filtering, editing, and deleting.
struct TransactionsView: View {

    /// ViewModel that manages the state and logic for transactions.
    @State private var viewModel: ViewModel

    /// The database manager to fetch and manipulate income and expense data.
    let databaseManager: DatabaseQueryType

    /// Initializes the TransactionsView with a provided database manager.
    init(databaseManager: DatabaseQueryType) {
        self.databaseManager = databaseManager
        self.viewModel = .init(databaseManager: databaseManager)
    }

    var body: some View {
        NavigationStack {
            VStack {
                /// Filter options view allowing users to select filters.
                FilterView(selectedFilterOptions: $viewModel.selectedFilterOptions) { filterOption in
                    switch filterOption {
                    case .date:
                        viewModel.showDateFilter.toggle()
                    case .source:
                        viewModel.showIncomeSourceFilter.toggle()
                    case .category:
                        viewModel.showExpenseCategoryFilter.toggle()
                    case .amount:
                        viewModel.showAmountFilter.toggle()
                    }
                }

                /// List displaying grouped transactions by month and year.
                List {
                    ForEach(viewModel.transactions, id: \.key) { monthYear, transactions in
                        HStack {
                            let components = monthYear.components(separatedBy: " ")
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
                        .listRowInsets(EdgeInsets())
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.primary.opacity(0.1))
                        .listRowSeparator(.hidden)

                        /// Display each transaction, with swipe actions for editing and deleting.
                        ForEach(transactions, id: \.id) { transaction in
                            if transaction is Expense {
                                ExpenseItemView(expense: transaction as! Expense)
                                    .swipeActions {
                                        Button("Delete", systemImage: "trash") {
                                            viewModel.expenseToDelete = transaction as? Expense
                                            viewModel.showExpenseDeleteConfirmation.toggle()
                                        }
                                        .tint(.red1)

                                        Button("Edit", systemImage: "pencil") {
                                            viewModel.expenseToUpdate = transaction as? Expense
                                        }
                                        .tint(.green1)
                                    }
                            } else {
                                IncomeItemView(income: transaction as! Income)
                                    .swipeActions {
                                        Button("Delete", systemImage: "trash") {
                                            viewModel.incomeToDelete = transaction as? Income
                                            viewModel.showIncomeDeleteConfirmation.toggle()
                                        }
                                        .tint(.red1)

                                        Button("Edit", systemImage: "pencil") {
                                            viewModel.incomeToUpdate = transaction as? Income
                                        }
                                        .tint(.green1)
                                    }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .padding(0)
            .searchable(text: $viewModel.searchText, prompt: "Search for a transaction")
            .navigationTitle("Transactions")
            .task {
                /// On view load, clear existing data and fetch transactions from database.
                viewModel.clearAllTransactions()
                viewModel.fetchExpenses()
                viewModel.fetchIncomes()
            }
            
            /// Sheet for filtering by expense category.
            .sheet(isPresented: $viewModel.showExpenseCategoryFilter) {
                MultipleSelectionView(items: Category.allCases.map{ MultipleSelectionItem(title: $0.rawValue, item: $0)}, title: "Expense Category") { selectedCategories in
                    viewModel.selectedCategories = selectedCategories
                    viewModel.selectedFilterOptions.insert(.category)
                }
                .presentationDetents([.fraction(0.75)])
                .presentationDragIndicator(.visible)
            }

            /// Sheet for filtering by income source.
            .sheet(isPresented: $viewModel.showIncomeSourceFilter) {
                MultipleSelectionView(items: Source.allCases.map{ MultipleSelectionItem(title: $0.rawValue, item: $0) }, title: "Income Source") { selectedSources in
                    viewModel.selectedSources = selectedSources
                    viewModel.selectedFilterOptions.insert(.source)
                }
                .presentationDetents([.fraction(0.66)])
                .presentationDragIndicator(.visible)
            }

            /// Sheet for filtering by amount range.
            .sheet(isPresented: $viewModel.showAmountFilter) {
                MultipleSelectionView(items: AmountRange.allCases.map{ MultipleSelectionItem(title: $0.title, item: $0) }, title: "Amount") { selectedAmountRanges in
                    viewModel.selectedAmountRanges = selectedAmountRanges
                    viewModel.selectedFilterOptions.insert(.amount)
                }
                .presentationDetents([.fraction(0.56)])
                .presentationDragIndicator(.visible)
            }

            /// Sheet for editing an expense.
            .sheet(item: $viewModel.expenseToUpdate) { item in
                EditExpenseView(expense: item, databaseManager: databaseManager, onUpdate:
                                    viewModel.fetchExpenses)
            }

            /// Sheet for editing an income.
            .sheet(item: $viewModel.incomeToUpdate) { item in
                EditIncomeView(income: item, databaseManager: databaseManager, onUpdate: viewModel.fetchIncomes)
            }

            /// Sheet for selecting date range.
            .sheet(isPresented: $viewModel.showDateFilter) {
                DateFilterView() { startDate, endDate in
                    viewModel.startDate = startDate
                    viewModel.endDate = endDate
                    viewModel.selectedFilterOptions.insert(.date)
                }
            }

            /// Alert to show general error messages.
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage)
            }

            /// Alert to confirm deletion of an expense.
            .alert("Delete", isPresented: $viewModel.showExpenseDeleteConfirmation, presenting: viewModel.expenseToDelete) { expense in
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.deleteExpense(expense.id)
                }
            } message: { expense in
                Text("Are you sure you want to delete \(expense.name)?")
            }

            /// Alert to confirm deletion of an income.
            .alert("Delete", isPresented: $viewModel.showIncomeDeleteConfirmation, presenting: viewModel.incomeToDelete) { income in
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.deleteIncome(income.id)
                }
            } message: { income in
                Text("Are you sure you want to delete \(income.source.rawValue)?")
            }
        }
    }
}

#Preview {
    TransactionsView(databaseManager: DatabaseManager(databaseHandler: DatabaseHandlerImpl(database: InMemoryDatabase())))
}
