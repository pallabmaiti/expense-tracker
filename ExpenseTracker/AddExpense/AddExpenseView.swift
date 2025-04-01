//
//  AddExpenseView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 27/03/25.
//

import SwiftUI

/// `AddExpenseView` is a SwiftUI view that allows users to add a new expense.
/// It provides fields for the name, amount, expense type, date, and notes associated with the expense.
/// The user can save the expense, and the view will notify the parent view by calling the `onSave` closure.
/// If an error occurs during the process, an error alert is shown to the user.
///
/// - Parameters:
///   - databaseManager: The `DatabaseQueryType` used to interact with the backend database for saving the expense.
///   - onSave: A closure called when the expense is successfully saved, allowing the parent view to refresh or update its data.

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    
    // ViewModel for managing the expense data and handling business logic.
    @State private var viewModel: ViewModel
    
    /// Boolean flags for displaying error and delete confirmation alerts.
    @State private var showError: Bool = false

    /// Error message to display in case of an error.
    @State private var errorMessage: String = ""

    // State properties for handling user input.
    @State private var amount: Double = 0
    @State private var expenseType: ExpenseType = .food
    @State private var date: Date = Date()
    @State private var name: String = ""
    @State private var note: String = ""
    
    // Closure called when the expense is successfully saved.
    var onSave: (() -> Void)
    
    // Initializer for the view, taking the databaseManager and onSave closure as parameters.
    init(databaseManager: DatabaseQueryType, onSave: @escaping () -> Void) {
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
                    TextField("Lunch, Dinner, etc.", text: $name)
                        .multilineTextAlignment(.trailing)
                }
                
                // Note field: Allows the user to enter any additional notes regarding the expense.
                HStack {
                    Text("Note")
                    Spacer()
                    TextField("Note", text: $note)
                        .multilineTextAlignment(.trailing)
                }
                
                // Amount field: Allows the user to enter the amount of the expense.
                HStack {
                    Text("Amount")
                    Spacer()
                    TextField("Amount", value: $amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                
                // Expense Type picker: Allows the user to select the type of the expense (e.g., Food, Transport, etc.).
                HStack {
                    Text("Expense Type")
                    Spacer()
                    Picker("Expense Type", selection: $expenseType) {
                        ForEach(ExpenseType.allCases, id: \.self) { type in
                            Text(type.rawValue)
                        }
                    }
                    .labelsHidden()
                }
                
                // Date picker: Allows the user to select the date for the expense.
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Save button: Initiates the process of adding the expense.
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", action: addExpense)
                        .disabled(name.isEmpty || amount == 0)
                }
                
                // Cancel button: Dismisses the view without saving the expense.
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            // Error alert: Displays an error message if something goes wrong while saving the expense.
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    /// Adds the expense by calling the `addExpense` method from the `ViewModel`.
    /// If the expense is successfully added, it calls the `onSave` closure and dismisses the view.
    /// If an error occurs, it shows an error alert with the appropriate message.
    func addExpense() {
        viewModel.addExpense(name: name, amount: amount, date: date.formattedString(), type: expenseType.rawValue, note: note) { result in
            switch result {
            case .success:
                onSave()  // Notify parent view to refresh data
                dismiss() // Dismiss the AddExpenseView
            case .failure(let error):
                showError.toggle()  // Show error alert
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    AddExpenseView(databaseManager: DatabaseManager(databaseHandler: DatabaseHandlerImpl())) { }
}
