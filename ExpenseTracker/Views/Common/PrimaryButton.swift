//
//  PrimaryButton.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 18/04/25.
//

import SwiftUI

struct PrimaryButton: View {
    @Environment(\.colorScheme) var colorScheme
    
    let title: String
    let isEnabled: Bool
    let action: () -> Void
    
    init(_ title: String, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.headline)
                .foregroundStyle(colorScheme == .dark ? .black : .white)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .disabled(!isEnabled)
        .background(isEnabled ? .green1 : .gray)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    PrimaryButton("Test", action: {})
}
