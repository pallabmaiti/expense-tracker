//
//  AddIncomeView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 03/04/25.
//

import SwiftUI

struct AddIncomeView: View {
    @Environment(\.dismiss) var dismiss
    
    // ViewModel for managing the income data and handling business logic.
    @State private var viewModel: ViewModel
        
    // Closure called when the income is successfully saved.
    var onSave: (() -> Void)
    
    // Initializer for the view, taking the databaseManager and onSave closure as parameters.
    init(databaseManager: DatabaseManager, onSave: @escaping () -> Void) {
        _viewModel = State(initialValue: .init(databaseManager: databaseManager))
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Amount field: Allows the user to enter the amount of the income.
                HStack {
                    Text("Amount")
                    Spacer()
                    TextField("Amount", value: $viewModel.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                
                // Source picker: Allows the user to select the type of the income (e.g., Salary, Rental, etc.).
                HStack {
                    Text("Source")
                    Spacer()
                    Picker("Source", selection: $viewModel.source) {
                        ForEach(Source.allCases, id: \.self) { source in
                            Text(source.rawValue)
                        }
                    }
                    .labelsHidden()
                }
                
                if viewModel.source == .other {
                    HStack {
                        Text("Note")
                        Spacer()
                        TextField("Note", text: $viewModel.note)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                // Date picker: Allows the user to select the date for the income.
                DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
            }
            .navigationTitle("Add Income")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Save button: Initiates the process of adding the income.
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", action: addIncome)
                        .disabled(viewModel.amount == 0)
                }
                
                // Cancel button: Dismisses the view without saving the income.
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            // Error alert: Displays an error message if something goes wrong while saving the income.
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }

    func addIncome() {
        Task {
            let success = await viewModel.addIncome()
            if success {
                onSave()  // Notify parent view to refresh data
                dismiss() // Dismiss the AddIncomeView
            }
        }
    }
}

#Preview {
    AddIncomeView(databaseManager: .initWithInMemory) { }
}
