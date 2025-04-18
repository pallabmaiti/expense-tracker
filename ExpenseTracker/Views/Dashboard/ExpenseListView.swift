//
//  ExpenseListView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 06/04/25.
//

import SwiftUI

/// `ExpenseItemView` is a SwiftUI `View` that represents a single expense item.
/// It displays the details of the expense, including its name, note, date, and amount.
/// The amount is color-coded based on its value for better visual indication.
struct ExpenseItemView: View {
    
    /// An instance of the `Expense` model containing details of the expense.
    let expense: Expense
    
    /// The body property defines the layout and visual components of the `ExpenseItemView`.
    var body: some View {
        HStack {
            Image(systemName: "arrow.up.right")
                .foregroundStyle(.red1)
                .padding(.trailing, 10)
            
            VStack(alignment: .leading) {
                // Displays the name of the expense in a headline font.
                Text(expense.name)
                    .font(.headline)
                
                // If the expense has a note, display it in a smaller font with a secondary foreground style.
                if !expense.note.isEmpty {
                    Text("(\(expense.note))")
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.secondary)
                }
                
                // Displays the date of the expense in a shortened format (abbreviated date, no time).
                Text(expense.formattedDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
            }
            
            Spacer()
            
            // Displays the amount of the expense in a currency format.
            // The currency symbol is based on the user's locale.
            Text("\(expense.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                .font(.headline)
        }
    }
}

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
