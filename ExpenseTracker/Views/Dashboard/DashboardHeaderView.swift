import SwiftUI

/// A header view for the dashboard that displays the currently selected month-year,
/// income, expense, and total balance, and allows the user to switch between months.
///
/// - Parameters:
///   - monthYears: The list of available month-year strings to choose from.
///   - selectedMonthYear: The index of the currently selected month-year in `monthYears`.
///   - totalIncome: The total income for the selected month.
///   - totalExpense: The total expense for the selected month.
///   - balance: The calculated balance (income minus expense) for the selected month.
///   - onSelectMonth: Closure called when a new month is selected, passing its index.
///   - onMonthChanged: Async closure to handle side effects when the month selection changes (e.g., data reload).
///
/// The view displays a dropdown menu for month selection and summarizes the financial
/// totals for the selected month. The styling and currency display use the user's current locale.
struct DashboardHeaderView: View {
    let monthYears: [String]
    let selectedMonthYear: Int
    let totalIncome: Double
    let totalExpense: Double
    let balance: Double
    let onSelectMonth: (Int) -> Void
    
    var body: some View {
        VStack {
            HStack {
                Text(monthYears[selectedMonthYear])
                    .font(.title2.bold())
                    .padding(.vertical, 5)
                Spacer()
                Menu {
                    ForEach(monthYears.indices, id: \.self) { index in
                        Button {
                            onSelectMonth(index)
                        } label: {
                            HStack {
                                Text(monthYears[index])
                                if selectedMonthYear == index {
                                    Image(systemName: "checkmark")
                                }
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
    }
}

#Preview {
    DashboardHeaderView(
        monthYears: ["April 2025", "May 2025"],
        selectedMonthYear: 0,
        totalIncome: 1000,
        totalExpense: 500,
        balance: 500,
        onSelectMonth: { _ in }
    )
}
