//
//  AddExpenseView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 27/03/25.
//

import SwiftUI

/// `AddExpenseView` is a SwiftUI view that allows users to add a new expense.
/// It provides fields for the name, amount, category, date, and notes associated with the expense.
/// The user can save the expense, and the view will notify the parent view by calling the `onSave` closure.
/// If an error occurs during the process, an error alert is shown to the user.
///
/// - Parameters:
///   - databaseManager: The `DatabaseManager` used to interact with the backend database for saving the expense.
///   - onSave: A closure called when the expense is successfully saved, allowing the parent view to refresh or update its data.

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    
    // ViewModel for managing the expense data and handling business logic.
    @State private var viewModel: ViewModel
        
    // Closure called when the expense is successfully saved.
    var onSave: (() -> Void)
    
    // Initializer for the view, taking the databaseManager and onSave closure as parameters.
    init(databaseManager: DatabaseManager, onSave: @escaping () -> Void) {
        _viewModel = State(initialValue: .init(databaseManager: databaseManager))
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Name field: Allows the user to enter the name of the expense (e.g., "Lunch", "Dinner").
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("Lunch, Dinner, etc.", text: $viewModel.name)
                        .multilineTextAlignment(.trailing)
                }
                
                // Note field: Allows the user to enter any additional notes regarding the expense.
                HStack {
                    Text("Note")
                    Spacer()
                    TextField("Note", text: $viewModel.note)
                        .multilineTextAlignment(.trailing)
                }
                
                // Amount field: Allows the user to enter the amount of the expense.
                HStack {
                    Text("Amount")
                    Spacer()
                    TextField("Amount", value: $viewModel.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                
                // Expense Type picker: Allows the user to select the category of the expense (e.g., Food, Transport, etc.).
                HStack {
                    Text("Category")
                    Spacer()
                    Picker("Category", selection: $viewModel.category) {
                        ForEach(Category.allCases, id: \.self) { category in
                            Text(category.rawValue)
                        }
                    }
                    .labelsHidden()
                }
                
                // Date picker: Allows the user to select the date for the expense.
                DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Save button: Initiates the process of adding the expense.
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", action: addExpense)
                        .disabled(viewModel.name.isEmpty || viewModel.amount == 0)
                }
                
                // Cancel button: Dismisses the view without saving the expense.
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            // Error alert: Displays an error message if something goes wrong while saving the expense.
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
    
    /// Adds the expense by calling the `addExpense` method from the `ViewModel`.
    /// If the expense is successfully added, it calls the `onSave` closure and dismisses the view.
    /// If an error occurs, it shows an error alert with the appropriate message.
    func addExpense() {
        Task {
            let success = await viewModel.addExpense()
            if success {
                dismiss()
                onSave()
            }
        }
    }
}

#Preview {
    AddExpenseView(databaseManager: DatabaseManager(databaseHandler: DatabaseHandlerImpl())) { }
}
