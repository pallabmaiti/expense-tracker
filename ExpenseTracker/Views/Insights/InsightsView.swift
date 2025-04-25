//
//  InsightsView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 02/04/25.
//

import SwiftUI
import Charts

/// Represents a single item to be shown in the chart (either an income source or an expense category).
struct InsightsChartItem: Identifiable {
    /// A unique identifier for the chart item.
    let id: String = UUID().uuidString
    
    /// The monetary amount associated with the item.
    let amount: Double
    
    /// The type or label (e.g., "Food", "Salary") shown for the item.
    let type: String
    
    /// The color associated with the item for chart representation.
    let color: Color
    
    /// Initializes an `InsightsChartItem` using an `Expense Category`.
    /// - Parameters:
    ///   - amount: Total amount for the category.
    ///   - category: The expense category.
    init(amount: Double, category: Category) {
        self.amount = amount
        self.type = category.rawValue
        switch category {
        case .food:
            self.color = .red
        case .shopping:
            self.color = .blue
        case .entertainment:
            self.color = .yellow
        case .travel:
            self.color = .green
        case .health:
            self.color = .orange
        case .other:
            self.color = .purple
        }
    }
    
    /// Initializes an `InsightsChartItem` using an `Income Source`.
    /// - Parameters:
    ///   - amount: Total amount for the source.
    ///   - source: The income source.
    init(amount: Double, source: Source) {
        self.amount = amount
        self.type = source.rawValue
        switch source {
        case .salary:
            self.color = .blue
        case .interest:
            self.color = .yellow
        case .rental:
            self.color = .red
        case .business:
            self.color = .orange
        case .other:
            self.color = .green
        }
    }
}

/// A SwiftUI view that displays a donut-style chart with a custom legend.
struct ChartView: View {
    /// The list of data items to display in the chart.
    let list: [InsightsChartItem]

    var body: some View {
        // Main donut chart
        Chart {
            ForEach(list) { item in
                SectorMark(
                    angle: .value("Amount", item.amount),
                    innerRadius: .ratio(0.6), // Creates donut effect
                    angularInset: 5
                )
                .cornerRadius(5)
                .foregroundStyle(item.color)
            }
        }
        .frame(height: 300)
        .padding(.vertical)
        
        // Custom legend below the chart
        VStack(alignment: .leading, spacing: 8) {
            ForEach(list) { item in
                HStack {
                    Circle()
                        .fill(item.color)
                        .frame(width: 12, height: 12)
                    Text("\(item.type): \(Locale.current.currencySymbol ?? "$")\(Int(item.amount))")
                        .font(.subheadline)
                }
            }
        }
        .padding(.top)
    }
}

/// A screen that shows a visual breakdown of expenses and incomes for the current month.
struct InsightsView: View {
    /// View model handling data operations and state.
    @State var viewModel: ViewModel
    
    /// The data source for fetching and managing income/expense data.
    let databaseManager: DatabaseManager

    /// Initializes the `InsightsView` with a given database manager.
    /// - Parameter databaseManager: Object conforming to `DatabaseManager` to handle data operations.
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
        self.viewModel = .init(databaseManager: databaseManager)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    VStack(alignment: .leading) {
                        // Current month header
                        Text(viewModel.currentMonth)
                            .font(.title2)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(.secondary)

                        // Expenses section
                        Text("Expenses")
                            .font(.headline)
                            .padding(.vertical, 10)

                        if viewModel.expenseList.isEmpty {
                            // Show add button if no expenses
                            AddTransactionButton {
                                viewModel.showAddExpense.toggle()
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            // Show expense chart
                            ChartView(list: viewModel.expenseList)
                        }

                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(.secondary)

                        // Incomes section
                        Text("Incomes")
                            .font(.headline)
                            .padding(.vertical, 10)

                        if viewModel.incomeList.isEmpty {
                            // Show add button if no incomes
                            AddTransactionButton {
                                viewModel.showAddIncome.toggle()
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            // Show income chart
                            ChartView(list: viewModel.incomeList)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Insights")
            .toolbarSyncButton()
            .task {
                Task {
                    // Fetch data when view appears
                    await viewModel.fetchIncomes()
                    await viewModel.fetchExpenses()
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
        }
    }
}


#Preview {
    InsightsView(databaseManager: DatabaseManager(databaseHandler: DatabaseHandlerImpl(database: InMemoryDatabase())))
}
