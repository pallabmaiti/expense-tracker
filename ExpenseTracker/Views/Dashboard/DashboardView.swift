//
//  DashboardView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 02/04/25.
//

import SwiftUI

/// The main dashboard view displaying expenses, balances, and expense management actions.
struct DashboardView: View {
    @EnvironmentObject var tabManager: TabManager
    /// The `ViewModel` instance that handles the data and business logic for the view.
    @State private var viewModel: ViewModel
    
    /// The total amount of income recorded.
    var totalIncome: Double {
        viewModel.incomeList.reduce(0) { $0 + $1.amount }
    }
    
    /// The total amount of expenses recorded.
    var totalExpense: Double {
        viewModel.expenseList.reduce(0) { $0 + $1.amount }
    }
    
    /// The net balance available after expenses.
    var balance: Double {
        totalIncome - totalExpense
    }
    
    /// The `databaseManager` object that handles the interaction with the data storage.
    let databaseManager: DatabaseManager
    
    /// Initializes the `DashboardView` with a given database manager.
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
        self.viewModel = .init(databaseManager: databaseManager)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                /// Displays incomes, expense and the total balance.
                Section {
                    HStack {
                        Text(viewModel.monthYears[viewModel.selectedMonthYear])
                            .font(.title2.bold())
                            .padding(.vertical, 5)
                        Spacer()
                        
                        Menu {
                            ForEach(viewModel.monthYears.indices, id: \.self) { index in
                                Button {
                                    viewModel.selectedMonthYear = index
                                    Task {
                                        await viewModel.fetchExpenses()
                                        await viewModel.fetchIncomes()
                                    }
                                } label: {
                                    Text(viewModel.monthYears[index])
                                    if viewModel.selectedMonthYear == index {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "chevron.up.chevron.down")
                        }
                    }
                    VStack {
                        HStack(spacing: 5) {
                            Text("Income")
                                .font(.headline)
                            Spacer()
                            Text("\(totalIncome, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                                .font(.subheadline)
                        }
                        .padding(.bottom, 5)
                        HStack(spacing: 5) {
                            Text("Expense")
                                .font(.headline)
                            Spacer()
                            Text("\(totalExpense, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                                .font(.subheadline)
                                .foregroundStyle(.red1)
                        }
                    }
                    .padding(.vertical, 5)
                    HStack(spacing: 5) {
                        Text("Total Balance")
                            .font(.title2)
                        Spacer()
                        Text("\(balance, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                            .font(.subheadline)
                            .foregroundStyle(balance >= 0 ? .green1 : .red1)
                    }
                    .padding(.vertical, 5)
                }
                
                /// Displays the list of recent expenses.
                Section {
                    ExpenseListView(
                        selectedSortingOption: $viewModel.sortingOption,
                        expenseList: viewModel.expenseList,
                        onSeeAll: {
                            tabManager.selectedTabIndex = 1
                        }, onSortingOrderChanged: { isDescending in
                            viewModel.isDescending = isDescending
                            viewModel.sortExpenses()
                        }, onSortingOptionChanged: { sortingOption in
                            viewModel.sortingOption = sortingOption
                            viewModel.sortExpenses()
                        }, onAddExpense: {
                            viewModel.showAddExpense.toggle()
                        }, onDeleteExpense: { expense in
                            viewModel.expenseToDelete = expense
                            viewModel.showExpenseDeleteConfirmation.toggle()
                        }, onUpdateExpense: { expense in
                            viewModel.expenseToUpdate = expense
                        })
                }
                
                /// Displays the list of recent incomes.
                Section {
                    IncomeListView(
                        incomeList: viewModel.incomeList,
                        onSeeAll: {
                            tabManager.selectedTabIndex = 1
                        }, onAddIncome: {
                            viewModel.showAddIncome.toggle()
                        }, onDeleteIncome: { income in
                            viewModel.incomeToDelete = income
                            viewModel.showIncomeDeleteConfirmation.toggle()
                        }, onUpdateIncome: { income in
                            viewModel.incomeToUpdate = income
                        })
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                Menu("Add", systemImage: "plus") {
                    Button {
                        viewModel.showAddIncome.toggle()
                    } label: {
                        Text("Income")
                        Image(systemName: "arrow.down.left")
                    }
                    Button {
                        viewModel.showAddExpense.toggle()
                    } label: {
                        Text("Expense")
                        Image(systemName: "arrow.up.right")
                    }
                }
            }
            .toolbarSyncButton() {
                Task {
                    await viewModel.fetchExpenses()
                    await viewModel.fetchIncomes()
                }
            }
            .sheet(isPresented: $viewModel.showAddExpense) {
                AddExpenseView(databaseManager: databaseManager) {
                    Task {
                        await viewModel.fetchExpenses()
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddIncome) {
                AddIncomeView(databaseManager: databaseManager) {
                    Task {
                        await viewModel.fetchIncomes()
                    }
                }
            }
            .sheet(item: $viewModel.expenseToUpdate) { item in
                EditExpenseView(expense: item, databaseManager: databaseManager) {
                    Task {
                        await viewModel.fetchExpenses()
                    }
                }
            }
            .sheet(item: $viewModel.incomeToUpdate) { item in
                EditIncomeView(income: item, databaseManager: databaseManager) {
                    Task {
                        await viewModel.fetchIncomes()
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .onAppear {
                Task {
                    await viewModel.fetchExpenses()
                    await viewModel.fetchIncomes()
                    await viewModel.prepareMonthYearSelection()
                }
            }
            .alert("Delete", isPresented: $viewModel.showExpenseDeleteConfirmation, presenting: viewModel.expenseToDelete) { expense in
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteExpense(expense)
                }
            } message: { expense in
                Text("Are you sure you want to delete \(expense.name)?")
            }
            .alert("Delete", isPresented: $viewModel.showIncomeDeleteConfirmation, presenting: viewModel.incomeToDelete) { income in
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteIncome(income)
                }
            } message: { income in
                Text("Are you sure you want to delete \(income.source.rawValue)?")
            }
        }
    }
    
    /// Deletes the selected expense from the database.
    /// - Parameter expense: The `Expense` object to be deleted.
    func deleteExpense(_ expense: Expense) {
        Task {
            await viewModel.deleteExpense(expense)
        }
    }
    
    /// Deletes the selected income from the database.
    /// - Parameter income: The `Income` object to be deleted.
    func deleteIncome(_ income: Income) {
        Task {
            await viewModel.deleteIncome(income)
        }
    }
}

#Preview {
    DashboardView(databaseManager: .initWithInMemory)
        .environmentObject(TabManager())
        .environment(DatabaseManager.initWithInMemory)
        .environment(\.authenticator, FirebaseAuthenticator())
        .environment(NotificationManager(center: .init(), settings: NotificationSettingsHandler()))
}
