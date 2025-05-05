//
//  FirebaseDatabase.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 23/04/25.
//

import FirebaseCore
import FirebaseFirestore
import Foundation

/// A Firestore-backed implementation of the `Database` protocol.
/// Handles CRUD operations for both expenses and incomes for a given user.
class FirebaseDatabase: Database {
    
    /// Firestore collection reference for the user's expenses.
    private let firestoreExpensesCollection: CollectionReference
    
    /// Firestore collection reference for the user's incomes.
    private let firestoreIncomesCollection: CollectionReference
    
    /// Initializes a Firestore database instance scoped to the given user ID.
    /// - Parameter userId: The unique identifier of the current authenticated user.
    init(userId: String) {
        let firestore = Firestore.firestore()
        self.firestoreExpensesCollection = firestore.collection("users").document(userId).collection("expenses")
        self.firestoreIncomesCollection = firestore.collection("users").document(userId).collection("incomes")
    }
    
    /// An array of `DatabaseIncome` representing all stored incomes.
    /// - SeeAlso: `Database.fetchExpenses()`
    func fetchExpenses() async throws -> [DatabaseExpense] {
        var _expenses: [DatabaseExpense] = []
        let documents = try await firestoreExpensesCollection.getDocuments().documents
        for document in documents {
            _expenses.append(try document.data(as: DatabaseExpense.self))
        }
        return _expenses
    }
    
    /// Adds a new expense to the database.
    /// - SeeAlso: `Database.addExpense(:)`
    func addExpense(_ expense: DatabaseExpense) async throws {
        if let data = try expense.data() {
            try await firestoreExpensesCollection.addDocument(data: data)
        } else {
            throw ExpenseTrackerError.invalidData
        }
    }

    /// Deletes an expense at the specified index.
    /// - SeeAlso: `Database.deleteExpense(:)`
    func deleteExpense(_ id: String) async throws {
        let documents = try await firestoreExpensesCollection.whereField("id", isEqualTo: id).getDocuments().documents
        documents.forEach{ $0.reference.delete() }
    }
    
    /// Updates an existing expense at the given index with a new expense.
    /// - SeeAlso: `Database.updateExpense(for:with:)`
    func updateExpense(for id: String, with newExpense: DatabaseExpense) async throws {
        let documents = try await firestoreExpensesCollection.whereField("id", isEqualTo: id).getDocuments().documents
        if let data = try newExpense.data() {
            documents.forEach{ $0.reference.updateData(data) }
        } else {
            throw ExpenseTrackerError.invalidData
        }
    }
    
    /// Clears all stored expenses from the database.
    /// - SeeAlso: `Database.clearExpenses()`
    func clearExpenses() async throws {
        let documents = try await firestoreExpensesCollection.getDocuments().documents
        documents.forEach { $0.reference.delete() }
    }
    
    /// An array of `DatabaseIncome` representing all stored incomes.
    /// - SeeAlso: `Database.fetchIncomes()`
    func fetchIncomes() async throws -> [DatabaseIncome] {
        var _incomes: [DatabaseIncome] = []
        let documents = try await firestoreIncomesCollection.getDocuments().documents
        for document in documents {
            let income = try document.data(as: DatabaseIncome.self)
            _incomes.append(income)
        }
        return _incomes
    }
    
    /// Adds a new income entry to the database.
    /// - SeeAlso: `Database.addIncome(:)`
    func addIncome(_ income: DatabaseIncome) async throws {
        if let data = try income.data() {
            try await firestoreIncomesCollection.addDocument(data: data)
        } else {
            throw ExpenseTrackerError.invalidData
        }
    }
    
    /// Deletes an income entry from the database at a specific index.
    /// - SeeAlso: `Database.deleteIncome(:)`
    func deleteIncome(_ id: String) async throws {
        let documents = try await firestoreIncomesCollection.whereField("id", isEqualTo: id).getDocuments().documents
        documents.forEach{ $0.reference.delete() }
    }
    
    /// Updates an existing income entry at a specific index with new data.
    /// - SeeAlso: `Database.updateIncome(for:with:)`
    func updateIncome(for id: String, with newIncome: DatabaseIncome) async throws {
        let documents = try await firestoreIncomesCollection.whereField("id", isEqualTo: id).getDocuments().documents
        if let data = try newIncome.data() {
            documents.forEach{ $0.reference.updateData(data) }
        } else {
            throw ExpenseTrackerError.invalidData
        }
    }
    
    /// Removes all income entries from the database.
    /// - SeeAlso: `Database.clearIncomes()`
    func clearIncomes() async throws {
        let documents = try await firestoreIncomesCollection.getDocuments().documents
        documents.forEach { $0.reference.delete() }
    }
}

/// Converts a `DatabaseExpense` into a dictionary format suitable for Firestore.
extension DatabaseExpense {
    func data() throws -> [String: Any]? {
        let encoded = try JSONEncoder().encode(self)
        return try JSONSerialization.jsonObject(with: encoded, options: []) as? [String: Any]
    }
}

/// Converts a `DatabaseIncome` into a dictionary format suitable for Firestore.
extension DatabaseIncome {
    func data() throws -> [String: Any]? {
        let encoded = try JSONEncoder().encode(self)
        return try JSONSerialization.jsonObject(with: encoded, options: []) as? [String: Any]
    }
}
