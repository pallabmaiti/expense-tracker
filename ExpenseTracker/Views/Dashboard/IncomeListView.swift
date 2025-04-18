//
//  IncomeListView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 06/04/25.
//

import SwiftUI

/// `IncomeItemView` is a SwiftUI `View` that represents a single income item.
/// It displays the details of the income, including its name, note, date, and amount.
/// The amount is color-coded based on its value for better visual indication.
struct IncomeItemView: View {
    
    /// An instance of the `Income` model containing details of the income.
    let income: Income
    
    /// The body property defines the layout and visual components of the `IncomeItemView`.
    var body: some View {
        HStack {
            Image(systemName: "arrow.down.left")
                .foregroundStyle(.green1)
                .padding(.trailing, 10)
            
            VStack(alignment: .leading) {
                // Displays the name of the income in a headline font.
                Text(income.source.rawValue)
                    .font(.headline)
                // Displays the date of the income in a shortened format (abbreviated date, no time).
                Text(income.formattedDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
            }
            
            Spacer()
            
            // Displays the amount of the income in a currency format.
            // The currency symbol is based on the user's locale.
            Text("\(income.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                .font(.headline)
        }
    }
}


/// A reusable view that displays a list of recent incomes with options to edit, delete, or add new incomes.
struct IncomeListView: View {
    
    /// The complete list of incomes passed to this view.
    let incomeList: [Income]
    
    /// Callback triggered when "See All" is tapped.
    var onSeeAll: () -> Void
    
    /// Callback triggered when the "Add Income" button is tapped.
    var onAddIncome: () -> Void
    
    /// Callback triggered when the user deletes an income entry.
    var onDeleteIncome: (Income) -> Void
    
    /// Callback triggered when the user taps to edit/update an income entry.
    var onUpdateIncome: (Income) -> Void

    /// A computed property that returns the last 10 incomes (or fewer).
    var last10Incomes: [Income] {
        if incomeList.count >= 10 {
            return Array(incomeList.prefix(10))
        } else {
            return incomeList
        }
    }

    var body: some View {
        // Header section: Title and See All
        HStack(spacing: 10) {
            Text("Recent Incomes")
                .font(.title2.bold())
            
            Spacer()
            
            if incomeList.count > 10 {
                Text("See All")
                    .foregroundStyle(.green1)
                    .onTapGesture {
                        onSeeAll()
                    }
            }
        }
        .padding(.vertical, 5)
        
        // Main content: Empty state or income list
        if last10Incomes.isEmpty {
            // If no incomes yet, show the Add button placeholder
            AddTransactionButton {
                onAddIncome()
            }
            .frame(maxWidth: .infinity)
        } else {
            
            // Show income items with swipe actions
            ForEach(last10Incomes, id: \.id) { income in
                IncomeItemView(income: income)
                    .swipeActions {
                        Button("Delete", systemImage: "trash") {
                            onDeleteIncome(income)
                        }
                        .tint(.red1)
                        
                        Button("Edit", systemImage: "pencil") {
                            onUpdateIncome(income)
                        }
                        .tint(.green1)
                    }
            }
        }
    }
}

#Preview {
    IncomeListView(incomeList: [.sample, .sample], onSeeAll: { }, onAddIncome: { }, onDeleteIncome: { _ in }, onUpdateIncome: { _ in })
}
