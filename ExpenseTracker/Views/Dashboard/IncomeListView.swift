//
//  IncomeListView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 06/04/25.
//

import SwiftUI

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
