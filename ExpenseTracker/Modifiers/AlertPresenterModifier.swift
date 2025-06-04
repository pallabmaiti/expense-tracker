//
//  AlertPresenterModifier.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 04/06/25.
//

import SwiftUI

enum AlertType: Identifiable {
    case error(message: String)
    case deleteExpense(Expense)
    case deleteIncome(Income)
    
    var id: String {
        switch self {
        case .error: return "error"
        case .deleteExpense: return "deleteExpense"
        case .deleteIncome: return "deleteIncome"
        }
    }
}

struct AlertPresenterModifier: ViewModifier {
    @Binding var alertType: AlertType?
    let onDeleteExpense: ((Expense) -> Void)?
    let onDeleteIncome: ((Income) -> Void)?
    
    func body(content: Content) -> some View {
        content
            .alert(item: $alertType) { type in
                switch type {
                case .error(let message):
                    return Alert(
                        title: Text("Error"),
                        message: Text(message),
                        dismissButton: .default(Text("OK"))
                    )
                    
                case .deleteExpense(let expense):
                    return Alert(
                        title: Text("Delete"),
                        message: Text("Are you sure you want to delete \(expense.name)?"),
                        primaryButton: .destructive(Text("Delete")) {
                            if let onDeleteExpense { onDeleteExpense(expense) }
                        },
                        secondaryButton: .cancel()
                    )
                    
                case .deleteIncome(let income):
                    return Alert(
                        title: Text("Delete"),
                        message: Text("Are you sure you want to delete \(income.source.rawValue)?"),
                        primaryButton: .destructive(Text("Delete")) {
                            if let onDeleteIncome { onDeleteIncome(income) }
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
    }
}

extension View {
    func alertPresenter(
        alertType: Binding<AlertType?>,
        onDeleteExpense: ((Expense) -> Void)? = nil,
        onDeleteIncome: ((Income) -> Void)? = nil
    ) -> some View {
        self.modifier(
            AlertPresenterModifier(
                alertType: alertType,
                onDeleteExpense: onDeleteExpense,
                onDeleteIncome: onDeleteIncome
            )
        )
    }
}
