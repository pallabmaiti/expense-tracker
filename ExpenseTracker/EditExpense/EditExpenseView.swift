//
//  EditExpenseView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 28/03/25.
//

import SwiftUI

/// `EditExpenseView` is a SwiftUI view that allows users to edit an existing expense.
/// It provides a form with input fields for the expense's name, note, amount, type, and date.
/// The view allows users to update or delete the expense and shows alerts for errors or delete confirmation.
struct EditExpenseView: View {
    
    /// Environment variable to dismiss the current view.
    @Environment(\.dismiss) var dismiss
    
    /// The view model for handling data-related operations.
    @State private var viewModel: ViewModel
    
    /// Boolean flags for displaying error and delete confirmation alerts.
    @State private var showError: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    
    /// State properties for storing the edited expense values.
    @State private var amount: Double
    @State private var expenseType: ExpenseType
    @State private var date: Date
    @State private var name: String
    @State private var note: String
    
    /// Error message to display in case of an error.
    @State private var errorMessage: String = ""
    
    /// The expense to be edited.
    let expense: Expense
    
    /// Closure that is executed when the expense is successfully updated.
    var onUpdate: () -> Void
    
    /// Initializes the `EditExpenseView` with the expense to edit and a closure to call after updating.
    /// - Parameters:
    ///   - expense: The `Expense` to be edited.
    ///   - databaseManager: The database manager responsible for performing data operations.
    ///   - onUpdate: A closure to call when the expense is successfully updated.
    init(expense: Expense, databaseManager: DatabaseQueryType, onUpdate: @escaping () -> Void) {
        self.expense = expense
        self.viewModel = .init(databaseManager: databaseManager)
        self.onUpdate = onUpdate
        _amount = State(initialValue: expense.amount)
        _expenseType = State(initialValue: expense.type)
        _date = State(initialValue: expense.date)
        _name = State(initialValue: expense.name)
        _note = State(initialValue: expense.note)
    }
    
    /// The body of the view, containing a form with input fields for the expense details and action buttons.
    var body: some View {
        NavigationStack {
            Form {
                // Name field
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("Lunch, Dinner, etc.", text: $name)
                        .multilineTextAlignment(.trailing)
                }
                
                // Note field
                HStack {
                    Text("Note")
                    Spacer()
                    TextField("Note", text: $note)
                        .multilineTextAlignment(.trailing)
                }
                
                // Amount field
                HStack {
                    Text("Amount")
                    Spacer()
                    TextField("Amount", value: $amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                
                // Expense type picker
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
                
                // Date picker
                DatePicker("Date", selection: $date, displayedComponents: .date)
                
                // Delete button
                Section {
                    Button {
                        showDeleteConfirmation.toggle()
                    } label: {
                        HStack(alignment: .center) {
                            Text("Delete")
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
            .navigationTitle("Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Update button
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Update", action: updateExpense)
                        .disabled(name.isEmpty || amount == 0)
                }
                
                // Cancel button
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .alert("Delete", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive, action: deleteExpense)
            } message: {
                Text("Are you sure you want to delete this expense?")
            }
        }
    }
    
    /// Updates the expense with the new values from the form.
    /// This method calls the view model to perform the update in the database and triggers the `onUpdate` closure on success.
    func updateExpense() {
        viewModel.updateExpense(id: expense.id, name: name, amount: amount, date: date.formattedString(), type: expenseType.rawValue, note: note) { result in
            switch result {
            case .success:
                onUpdate()
                dismiss()
            case .failure(let error):
                showError.toggle()
                errorMessage = error.localizedDescription
            }
        }
    }
    
    /// Deletes the expense.
    /// This method calls the view model to perform the delete operation and dismisses the view on success.
    func deleteExpense() {
        viewModel.deleteExpense(id: expense.id) { result in
            switch result {
            case .success:
                dismiss()
            case .failure(let error):
                showError.toggle()
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    let expense: Expense = .init(id: UUID().uuidString, name: "Test", amount: 100.0, date: Date(), type: .food, note: "")
    EditExpenseView(expense: expense, databaseManager: DatabaseManager(databaseHandler: DatabaseHandlerImpl())) { }
}
