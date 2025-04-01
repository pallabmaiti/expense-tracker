//
//  ExpenseListView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 27/03/25.
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
        VStack {
            HStack {
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
                    Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                }
                
                Spacer()
                
                // Displays the amount of the expense in a currency format.
                // The currency symbol is based on the user's locale.
                Text("\(expense.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                    .font(.headline)
                    .foregroundStyle(
                        // Color the amount based on its value:
                        // - Green if the amount is less than or equal to 100
                        // - Orange if the amount is less than or equal to 500
                        // - Red if the amount is greater than 500
                        expense.amount.isLessThanOrEqualTo(100) ? Color.green1 :
                            expense.amount.isLessThanOrEqualTo(500) ? Color.orange : Color.red1
                    )
            }
        }
    }
}

/// `ExpenseMonthView` is a SwiftUI `View` that represents a list of expenses for a specific month.
/// It displays the month name, the total amount of expenses for that month, and a list of individual expenses.
/// Each expense in the list can be deleted or updated via swipe actions.
struct ExpenseMonthView: View {
    
    /// The month (e.g., "January", "February", etc.) that this view is representing.
    let month: String
    
    /// An array of `Expense` objects representing the expenses for the given month.
    let expenses: [Expense]
    
    /// A closure that will be called when an expense is deleted.
    let delete: (Expense) -> Void
    
    /// A closure that will be called when an expense is updated.
    let update: (Expense) -> Void
    
    /// A computed property that calculates the total expenses for the month.
    var totalExpense: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    /// The body property defines the layout and visual components of the `ExpenseMonthView`.
    var body: some View {
        VStack(alignment: .leading) {
            // Display the month name in uppercase with a bold title style.
            Text(month.uppercased())
                .font(.title3.bold())
                .foregroundStyle(.red1)
            
            // Display the total expenses for the month, formatted as a currency.
            Text("Total expenses: \(totalExpense, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                .font(.subheadline)
        }
        
        // Iterate over the `expenses` array to display each individual expense.
        ForEach(expenses, id: \.id) { expense in
            // Display each `Expense` using the `ExpenseItemView`.
            ExpenseItemView(expense: expense)
                .swipeActions {
                    // Provide swipe actions for deleting and updating the expense.
                    Button("Delete", systemImage: "trash") {
                        delete(expense)
                    }
                    .tint(.red1)
                    
                    Button("Edit", systemImage: "pencil") {
                        update(expense)
                    }
                    .tint(.green1)
                }
        }
    }
}

/// `ExpenseYearView` is a SwiftUI `View` that displays the expenses for each month of a given year.
/// It shows the year as the section header and, for each month with expenses, displays the associated `ExpenseMonthView`.
/// The view also allows for deleting and updating expenses for each month.
struct ExpenseYearView: View {
    
    /// The `ExpenseData` object that holds expenses for the specific year.
    let expenseData: ExpenseData
    
    /// A closure that is called when an expense is deleted.
    let delete: (Expense) -> Void
    
    /// A closure that is called when an expense is updated.
    let update: (Expense) -> Void
    
    /// The body property defines the layout and visual components of the `ExpenseYearView`.
    var body: some View {
        Section(header: Text("\(expenseData.year)")) {
            // Iterate through all months in reverse order (starting from December)
            ForEach(Month.allCases.reversed(), id: \.self) { month in
                // For each month, check if there are any expenses for that month.
                // If there are expenses, create an `ExpenseMonthView` to display them.
                switch month {
                case .january:
                    if expenseData.expenses.january.isNotEmpty {
                        ExpenseMonthView(month: month.name, expenses: expenseData.expenses.january, delete: delete, update: update)
                    }
                case .february:
                    if expenseData.expenses.february.isNotEmpty {
                        ExpenseMonthView(month: month.name, expenses: expenseData.expenses.february, delete: delete, update: update)
                    }
                case .march:
                    if expenseData.expenses.march.isNotEmpty {
                        ExpenseMonthView(month: month.name, expenses: expenseData.expenses.march, delete: delete, update: update)
                    }
                case .april:
                    if expenseData.expenses.april.isNotEmpty {
                        ExpenseMonthView(month: month.name, expenses: expenseData.expenses.april, delete: delete, update: update)
                    }
                case .may:
                    if expenseData.expenses.may.isNotEmpty {
                        ExpenseMonthView(month: month.name, expenses: expenseData.expenses.may, delete: delete, update: update)
                    }
                case .june:
                    if expenseData.expenses.june.isNotEmpty {
                        ExpenseMonthView(month: month.name, expenses: expenseData.expenses.june, delete: delete, update: update)
                    }
                case .july:
                    if expenseData.expenses.july.isNotEmpty {
                        ExpenseMonthView(month: month.name, expenses: expenseData.expenses.july, delete: delete, update: update)
                    }
                case .august:
                    if expenseData.expenses.august.isNotEmpty {
                        ExpenseMonthView(month: month.name, expenses: expenseData.expenses.august, delete: delete, update: update)
                    }
                case .september:
                    if expenseData.expenses.september.isNotEmpty {
                        ExpenseMonthView(month: month.name, expenses: expenseData.expenses.september, delete: delete, update: update)
                    }
                case .october:
                    if expenseData.expenses.october.isNotEmpty {
                        ExpenseMonthView(month: month.name, expenses: expenseData.expenses.october, delete: delete, update: update)
                    }
                case .november:
                    if expenseData.expenses.november.isNotEmpty {
                        ExpenseMonthView(month: month.name, expenses: expenseData.expenses.november, delete: delete, update: update)
                    }
                case .december:
                    if expenseData.expenses.december.isNotEmpty {
                        ExpenseMonthView(month: month.name, expenses: expenseData.expenses.december, delete: delete, update: update)
                    }
                }
            }
        }
    }
}

/// `ExpenseListView` is a SwiftUI `View` that displays a list of expenses grouped by year.
/// It allows the user to add, update, delete, and sort expenses. It also supports error handling and sorting options.
struct ExpenseListView: View {
    
    /// The `ViewModel` instance that handles the data and business logic for the view.
    @State private var viewModel: ViewModel
    
    /// A state variable to control the visibility of the Add Expense sheet.
    @State private var showAddExpense: Bool = false
    
    /// A state variable to control the visibility of the delete confirmation alert.
    @State private var showDeleteConfirmation: Bool = false
    
    /// A state variable to control the visibility of error messages.
    @State private var showError: Bool = false
    
    /// The expense that the user wants to delete.
    @State private var expenseToDelete: Expense? = nil
    
    /// The expense that the user wants to update.
    @State private var expenseToUpdate: Expense?
    
    /// A state variable that holds the error message to be displayed.
    @State private var errorMessage: String = ""
    
    /// A state variable that holds the navigation path for navigation-based actions.
    @State private var path = NavigationPath()
    
    /// The `databaseManager` object that handles the interaction with the data storage (e.g., DatabaseQuery or database).
    let databaseManager: DatabaseQueryType
    
    /// The initializer for the `ExpenseListView`. It takes a `databaseManager` as a parameter.
    init(databaseManager: DatabaseQueryType) {
        self.databaseManager = databaseManager
        self.viewModel = .init(databaseManager: databaseManager)
    }
    
    /// The body of the view defines the layout and visual components of `ExpenseListView`.
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    // Iterates through each `ExpenseData` (grouped by year) and displays them using `ExpenseYearView`
                    ForEach(viewModel.expenseDataList, id: \.year) { item in
                        ExpenseYearView(expenseData: item) { expense in
                            expenseToDelete = expense
                            showDeleteConfirmation.toggle() // Shows confirmation for deletion
                        } update: { expense in
                            expenseToUpdate = expense // Prepares expense for updating
                        }
                    }
                }
            }
            .navigationTitle("Expense Tracker")
            .toolbar {
                // Sorting Picker to allow the user to change the sorting option
                ToolbarItem(placement: .topBarTrailing) {
                    Picker("Sort", systemImage: "arrow.up.arrow.down", selection: $viewModel.sortingOption) {
                        ForEach(SortingOption.allCases, id: \.self) { options in
                            Text(options.rawValue)
                        }
                    } currentValueLabel: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    .labelsHidden()
                    .disabled(viewModel.expenseDataList.isEmpty)
                    .onChange(of: viewModel.sortingOption, { _, _ in
                        viewModel.updateSorting() // Updates the sorting whenever the option changes
                    })
                }
                // Add Expense Button
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Expense", systemImage: "plus") {
                        showAddExpense.toggle() // Shows the Add Expense view when tapped
                    }
                }
            }
            // Add Expense Sheet
            .sheet(isPresented: $showAddExpense) {
                AddExpenseView(databaseManager: databaseManager) {
                    fetchExpenses() // Refresh expenses after adding
                }
            }
            // Edit Expense Sheet
            .sheet(item: $expenseToUpdate) { item in
                EditExpenseView(expense: item, databaseManager: databaseManager) {
                    fetchExpenses() // Refresh expenses after editing
                }
            }
            // Error Alert
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage) // Displays the error message if an error occurs
            }
            // Fetch Expenses when the view appears
            .task {
                fetchExpenses()
            }
            // Delete Confirmation Alert
            .alert("Delete", isPresented: $showDeleteConfirmation, presenting: expenseToDelete) { expense in
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteExpense(expense) // Calls the delete function when confirmed
                }
            } message: { expense in
                Text("Are you sure you want to delete \(expense.name)?") // Message displayed for the delete confirmation
            }
        }
    }
    
    /// Deletes the selected expense from the database.
    func deleteExpense(_ expense: Expense) {
        viewModel.deleteExpense(id: expense.id) { result in
            switch result {
            case .success:
                self.fetchExpenses() // Refresh expenses after deletion
            case .failure(let error):
                showError.toggle() // Show error if deletion fails
                errorMessage = error.localizedDescription
            }
        }
    }
    
    /// Fetches the list of expenses from the database and updates the view model.
    func fetchExpenses() {
        viewModel.fetchExpenses { result in
            if case let .failure(error) = result {
                showError.toggle() // Show error if fetching fails
                errorMessage = error.localizedDescription
            }
        }
    }
}

/// `InMemoryDatabase` is an implementation of the `Database` protocol that simulates a local in-memory database.
/// It stores expenses in an array and provides methods to add, delete, update, and clear expenses.
/// It uses a `DispatchQueue` for thread-safety when modifying the underlying data.
class InMemoryDatabase: Database {
    
    /// A private array holding the in-memory expenses.
    private var _expenses: [DatabaseExpense] = [.sample1, .sample2, .sample3, .sample4, .sample5, .sample6, .sample7, .sample8]
    
    /// A `DispatchQueue` used for synchronizing access to the in-memory database to ensure thread safety.
    private let queue = DispatchQueue(label: "com.ExpenseTracker.InMemoryDatabase")

    /// A computed property that returns the list of expenses in the database.
    /// Access is synchronized using the `queue`.
    var expenses: [DatabaseExpense] {
        queue.sync { [weak self] in
            guard let self else { return [] }
            return _expenses
        }
    }
    
    /// Adds a new expense to the database.
    /// - Parameter expense: The `DatabaseExpense` to be added.
    func addExpense(_ expense: DatabaseExpense) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            _expenses.append(expense) // Adds the expense to the in-memory list
        }
    }
    
    /// Deletes an expense from the database at a specific index.
    /// - Parameter index: The index of the expense to be deleted.
    func deleteExpense(at index: Int) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            _expenses.remove(at: index) // Removes the expense at the given index
        }
    }
    
    /// Updates an existing expense at a specific index with a new expense.
    /// - Parameters:
    ///   - index: The index of the expense to be updated.
    ///   - newExpense: The `DatabaseExpense` that will replace the existing expense.
    func updateExpense(at index: Int, with newExpense: DatabaseExpense) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            _expenses[index] = newExpense // Updates the expense at the specified index
        }
    }
    
    /// Clears all expenses from the database.
    func clearExpenses() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            _expenses.removeAll() // Removes all expenses from the in-memory list
        }
    }
}


#Preview {
    ExpenseListView(databaseManager: DatabaseManager(databaseHandler: DatabaseHandlerImpl(database: InMemoryDatabase())))
}
