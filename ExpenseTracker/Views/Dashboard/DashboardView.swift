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
    
    /// Initializes the `DashboardView` with a given database manager.
    init(databaseManager: DatabaseManager) {
        _viewModel = .init(initialValue: .init(databaseManager: databaseManager))
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
                            Text("\(viewModel.totalIncome, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                                .font(.subheadline)
                        }
                        .padding(.bottom, 5)
                        HStack(spacing: 5) {
                            Text("Expense")
                                .font(.headline)
                            Spacer()
                            Text("\(viewModel.totalExpense, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                                .font(.subheadline)
                                .foregroundStyle(.red1)
                        }
                    }
                    .padding(.vertical, 5)
                    HStack(spacing: 5) {
                        Text("Total Balance")
                            .font(.title2)
                        Spacer()
                        Text("\(viewModel.balance, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                            .font(.subheadline)
                            .foregroundStyle(viewModel.balance >= 0 ? .green1 : .red1)
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
                        },
                        onSortingOrderChanged: { isDescending in
                            viewModel.isDescending = isDescending
                            viewModel.sortExpenses()
                        },
                        onSortingOptionChanged: { sortingOption in
                            viewModel.sortingOption = sortingOption
                            viewModel.sortExpenses()
                        },
                        onAddExpense: {
                            viewModel.presentedSheet = .addExpense(viewModel.databaseManager)
                        },
                        onDeleteExpense: { expense in
                            viewModel.alertType = .deleteExpense(expense)
                        },
                        onUpdateExpense: { expense in
                            viewModel.presentedSheet = .editExpense(viewModel.databaseManager, expense)
                        }
                    )
                }
                
                /// Displays the list of recent incomes.
                Section {
                    IncomeListView(
                        incomeList: viewModel.incomeList,
                        onSeeAll: {
                            tabManager.selectedTabIndex = 1
                        },
                        onAddIncome: {
                            viewModel.presentedSheet = .addIncome(viewModel.databaseManager)
                        },
                        onDeleteIncome: { income in
                            viewModel.alertType = .deleteIncome(income)
                        },
                        onUpdateIncome: { income in
                            viewModel.presentedSheet = .editIncome(viewModel.databaseManager, income)
                        }
                    )
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                Menu("Add", systemImage: "plus") {
                    Button {
                        viewModel.presentedSheet = .addIncome(viewModel.databaseManager)
                    } label: {
                        Text("Income")
                        Image(systemName: "arrow.down.left")
                    }
                    Button {
                        viewModel.presentedSheet = .addExpense(viewModel.databaseManager)
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
            .sheetPresenter(
                presentedSheet: $viewModel.presentedSheet,
                onExpenseAdd: {
                    Task { await viewModel.fetchExpenses() }
                },
                onIncomeAdd: {
                    Task { await viewModel.fetchIncomes() }
                },
                onExpenseUpdate: {
                    Task { await viewModel.fetchExpenses() }
                },
                onIncomeUpdate: {
                    Task { await viewModel.fetchIncomes() }
                }
            )
            .onAppear {
                Task {
                    await viewModel.fetchExpenses()
                    await viewModel.fetchIncomes()
                    await viewModel.prepareMonthYearSelection()
                }
            }
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
    DashboardView(databaseManager: .initWithInMemory)
        .environmentObject(TabManager())
        .environment(DatabaseManager.initWithInMemory)
        .environment(\.authenticator, FirebaseAuthenticator())
        .environment(NotificationManager(center: .init(), settings: NotificationSettingsHandler()))
}
