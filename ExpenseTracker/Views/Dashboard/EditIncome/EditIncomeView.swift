//
//  EditIncomeView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 03/04/25.
//

import SwiftUI

/// `EditIncomeView` is a SwiftUI view that allows users to edit an existing income.
/// It provides a form with input fields for the income's amount, source, and date.
/// The view allows users to update or delete the income and shows alerts for errors or delete confirmation.
struct EditIncomeView: View {
    
    /// Environment variable to dismiss the current view.
    @Environment(\.dismiss) var dismiss
    
    /// The view model for handling data-related operations.
    @State private var viewModel: ViewModel
        
    /// Closure that is executed when the income is successfully updated.
    var onUpdate: () -> Void
    
    /// Initializes the `EditIncomeView` with the income to edit and a closure to call after updating.
    /// - Parameters:
    ///   - income: The `Income` to be edited.
    ///   - databaseManager: The database manager responsible for performing data operations.
    ///   - onUpdate: A closure to call when the income is successfully updated.
    init(income: Income, databaseManager: DatabaseManager, onUpdate: @escaping () -> Void) {
        self.viewModel = .init(income: income, databaseManager: databaseManager)
        self.onUpdate = onUpdate
    }
    
    /// The body of the view, containing a form with input fields for the income details and action buttons.
    var body: some View {
        NavigationStack {
            Form {
                // Amount field
                HStack {
                    Text("Amount")
                    Spacer()
                    TextField("Amount", value: $viewModel.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                
                // Source picker
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
                
                // Date picker
                DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
                
                // Delete button
                Section {
                    Button {
                        viewModel.showDeleteConfirmation.toggle()
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
            .navigationTitle("Edit Income")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Update button
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Update", action: updateIncome)
                        .disabled(viewModel.amount == 0)
                }
                
                // Cancel button
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .alert("Delete", isPresented: $viewModel.showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive, action: deleteIncome)
            } message: {
                Text("Are you sure you want to delete this income?")
            }
        }
    }
    
    /// Updates the income with the new values from the form.
    /// This method calls the view model to perform the update in the database and triggers the `onUpdate` closure on success.
    func updateIncome() {
        Task {
            let success = await viewModel.updateIncome()
            if success {
                onUpdate()
                dismiss()
            }
        }
    }
    
    /// Deletes the income.
    /// This method calls the view model to perform the delete operation and dismisses the view on success.
    func deleteIncome() {
        Task {
            let success = await viewModel.deleteIncome()
            if success {
                onUpdate()
                dismiss()
            }
        }
    }
}

#Preview {
    EditIncomeView(income: .sample, databaseManager: DatabaseManager(databaseHandler: DatabaseHandlerImpl())) { }
}
