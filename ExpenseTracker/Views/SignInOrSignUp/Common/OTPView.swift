//
//  OTPView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 19/04/25.
//

import SwiftUI

struct OTPView: View {
    let numberOfFields: Int
    @Binding var otpCode: String
    @State private var otpDigits: [String]
    @FocusState private var focusedField: Int?
    
    init(numberOfFields: Int = 6, otpCode: Binding<String>) {
        self.numberOfFields = numberOfFields
        self._otpCode = otpCode
        self._otpDigits = State(initialValue: Array(repeating: "", count: numberOfFields))
    }
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(0..<numberOfFields, id: \.self) { index in
                TextField("", text: $otpDigits[index])
                    .font(.title)
                    .tint(.clear)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .frame(height: 70)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke((otpDigits[index].isNotEmpty || focusedField == index) ? .green1 : .gray, lineWidth: 1.5)
                    )
                    .focused($focusedField, equals: index)
                    .onChange(of: otpDigits[index]) { oldValue, newValue in
                        processInput(index: index, oldValue: oldValue, newValue: newValue)
                    }
                    .onTapGesture {
                        focusedField = index
                    }
            }
        }
        .onAppear {
            focusedField = 0
        }
        .onChange(of: otpDigits) { _, _ in
            updateOTPCode()
        }
    }
    
    private func processInput(index: Int, oldValue: String, newValue: String) {
        // Limit to single digit
        if newValue.count > 1 {
            let filtered = newValue.filter { $0.isNumber && String($0) != oldValue }
            otpDigits[index] = filtered.isEmpty ? oldValue : String(filtered.prefix(1))
        }
        
        // Auto-navigation
        if !newValue.isEmpty && index < numberOfFields - 1 {
            focusedField = index + 1
        } else if newValue.isEmpty && index > 0 {
            focusedField = index - 1
        }
    }
    
    private func updateOTPCode() {
        otpCode = otpDigits.joined()
    }
}

#Preview {
    OTPView(otpCode: .constant(""))
}
