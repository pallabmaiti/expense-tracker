//
//  DateFilterView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 07/04/25.
//

import SwiftUI

/// A view that allows the user to select a date filter range (e.g., last 30/60/90 days or custom).
struct DateFilterView: View {
    
    /// Enum representing the available date filter options.
    enum DateFilterOption: String, CaseIterable, Identifiable {
        case last30Days = "Last 30 Days"
        case last60Days = "Last 60 Days"
        case last90Days = "Last 90 Days"
        case customRange = "Custom Range"
        
        var id: String { rawValue }
    }

    /// Used to dismiss the current view (in a sheet or navigation stack).
    @Environment(\.dismiss) var dismiss
    
    /// The currently selected date filter option.
    @State private var selectedOption: DateFilterOption?
    
    /// Start date for the custom range (defaulted to 7 days ago).
    @State private var startDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    
    /// End date for the custom range (defaulted to today).
    @State private var endDate: Date = Date()
    
    /// Callback triggered when a valid date range is applied.
    var onSelectDateRange: ((Date, Date) -> Void)

    /// Computes the final selected date range based on the selected option.
    private var selectedDateRange: (Date, Date)? {
        guard let selectedOption else {
            return nil
        }
        let now = Date()
        switch selectedOption {
        case .last30Days:
            return (Calendar.current.date(byAdding: .day, value: -30, to: now)!, now)
        case .last60Days:
            return (Calendar.current.date(byAdding: .day, value: -60, to: now)!, now)
        case .last90Days:
            return (Calendar.current.date(byAdding: .day, value: -90, to: now)!, now)
        case .customRange:
            return (startDate, endDate)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                // Header with title and dismiss button
                HStack {
                    Text("Date")
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                .padding(20)
                
                // Display all available date filter options
                ForEach(DateFilterOption.allCases) { option in
                    Button(action: {
                        selectedOption = option
                    }) {
                        HStack {
                            Text(option.rawValue)
                            Spacer()
                                Image(systemName: selectedOption == option ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedOption == option ? .green1 : .gray)
                        }
                        .padding(20)
                        .background(selectedOption == option ? Color.gray.opacity(0.2) : Color.clear)
                        .listRowInsets(EdgeInsets())
                    }
                    .tint(Color.primary)
                }
                
                // Show date pickers when custom range is selected
                if selectedOption == .customRange {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Start Date")
                            Spacer()
                            DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
                            .labelsHidden()
                        }
                        HStack {
                            Text("End Date")
                            Spacer()
                            DatePicker("End Date", selection: $endDate, in: startDate...Date(), displayedComponents: [.date])
                                .labelsHidden()
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                }
                
                // Buttons to clear or apply the selection
                HStack(spacing: 20) {
                    Spacer()
                    Button("Clear") {
                        selectedOption = nil
                    }
                    Button("Apply") {
                        if let selectedDateRange {
                            onSelectDateRange(selectedDateRange.0, selectedDateRange.1)
                        }
                        dismiss()
                    }
                    .disabled(selectedOption == nil)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(selectedOption == nil ? .gray.opacity(0.5) : .green1.opacity(0.3))
                    .clipShape(.capsule)
                    .foregroundStyle(.primary)
                }
                .padding()

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    DateFilterView() { _, _ in }
}
