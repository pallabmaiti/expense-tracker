//
//  ExpenseListView 2.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 28/05/25.
//

import SwiftUI

/// A reusable component for displaying a list of recent expenses with sorting, deletion, and editing capabilities.
struct ExpenseListView: View {
    
    /// Indicates whether the sorting order is descending (true) or ascending (false).
    @State private var isDescending = true
    
    @Binding var selectedSortingOption: SortingOption
    
    /// The complete list of expenses provided to this view.
    let expenseList: [Expense]
    
    /// Callback triggered when "See All" is tapped.
    var onSeeAll: () -> Void
    
    /// Callback triggered when the sorting order changes (ascending/descending).
    var onSortingOrderChanged: (Bool) -> Void
    
    /// Callback triggered when the sorting option (date, amount, name) is changed.
    var onSortingOptionChanged: (SortingOption) -> Void
    
    /// Callback triggered when the "Add Expense" button is tapped.
    var onAddExpense: () -> Void
    
    /// Callback triggered when the user deletes an expense.
    var onDeleteExpense: (Expense) -> Void
    
    /// Callback triggered when the user wants to edit/update an expense.
    var onUpdateExpense: (Expense) -> Void
    
    /// A computed property that returns the last 10 expenses (or fewer if less than 10 exist).
    var last10Expenses: [Expense] {
        if expenseList.count >= 10 {
            return Array(expenseList.prefix(10))
        } else {
            return expenseList
        }
    }
    
    var body: some View {
        // Header: Title, See All, Sorting Buttons
        HStack(spacing: 10) {
            Text("Recent Expenses")
                .font(.title2.bold())
            
            Spacer()
            
            if expenseList.count > 10 {
                Text("See All")
                    .foregroundStyle(.green1)
                    .onTapGesture {
                        onSeeAll()
                    }
            }
            
            // Toggle sorting order button
            Image(systemName: isDescending ? "arrowtriangle.down.fill" : "arrowtriangle.up.fill")
                .foregroundStyle(.green1)
                .onTapGesture {
                    isDescending.toggle()
                    onSortingOrderChanged(isDescending)
                }
            
            // Sorting options menu
            Menu {
                ForEach(SortingOption.allCases, id: \.self) { sortingOption in
                    Button {
                        onSortingOptionChanged(sortingOption)
                    } label: {
                        Text(sortingOption.rawValue)
                        Image(systemName: selectedSortingOption == sortingOption ? "checkmark" : sortingOption.systemImageName)
                    }
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down")
            }
        }
        .padding(.vertical, 5)
        
        // Content section
        if last10Expenses.isEmpty {
            // Show placeholder + Add Expense if list is empty
            AddTransactionButton {
                onAddExpense()
            }
            .frame(maxWidth: .infinity)
        } else {
            // Show list of recent expenses with swipe actions
            ForEach(last10Expenses, id: \.id) { expense in
                ExpenseItemView(expense: expense)
                    .swipeActions {
                        Button("Delete", systemImage: "trash") {
                            onDeleteExpense(expense)
                        }
                        .tint(.red1)
                        
                        Button("Edit", systemImage: "pencil") {
                            onUpdateExpense(expense)
                        }
                        .tint(.green1)
                    }
            }
        }
    }
}

#Preview {
    ExpenseListView(selectedSortingOption: .constant(.date), expenseList: [.sample], onSeeAll: { }, onSortingOrderChanged: { _ in }, onSortingOptionChanged: { _ in }, onAddExpense: { }, onDeleteExpense: { _ in }, onUpdateExpense: { _ in })
}
