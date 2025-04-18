//
//  SecondaryButton.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 19/04/25.
//

import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.green1, lineWidth: 1)
        }
    }
}

#Preview {
    SecondaryButton("Save", action: { })
}
