//
//  MultipleSelectionView.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 03/04/25.
//

import SwiftUI

/// A generic model representing a selectable item with a title and an associated value.
struct MultipleSelectionItem<T: Hashable>: Hashable {
    /// The display title for the item.
    let title: String
    
    /// The actual item of generic type `T`.
    let item: T
}

/// A reusable SwiftUI view for selecting multiple items from a list.
struct MultipleSelectionView<T: Hashable>: View {
    @Environment(\.dismiss) var dismiss
    
    /// Stores the currently selected items.
    @State private var selectedItems: Set<MultipleSelectionItem<T>> = []

    /// The list of available items to display.
    let items: [MultipleSelectionItem<T>]
    
    /// The title to display in the navigation bar.
    let title: String
    
    /// Closure called when the user finishes selection, returning selected items of type `T`.
    let onSelection: ([T]) -> Void

    /// Initializes the multiple selection view.
    /// - Parameters:
    ///   - items: The list of items to choose from.
    ///   - title: The title shown at the top of the screen.
    ///   - onSelection: A closure that returns the final selection.
    init(items: [MultipleSelectionItem<T>], title: String, onSelection: @escaping ([T]) -> Void) {
        self.items = items
        self.title = title
        self.onSelection = onSelection
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
            .padding(20)
            
            ForEach(items, id: \.self) { item in
                MultipleSelectionRow(
                    title: item.title,
                    isSelected: selectedItems.contains(item)
                ) {
                    toggleSelection(of: item)
                }
                .tint(Color.primary)
            }
            
            HStack(spacing: 20) {
                Spacer()
                Button("Clear") {
                    selectedItems.removeAll()
                }
                Button("Apply") {
                    onSelection(selectedItems.map { $0.item })
                    dismiss()
                }
                .disabled(selectedItems.isEmpty)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(selectedItems.isEmpty ? .gray.opacity(0.5) : .green1.opacity(0.3))
                .clipShape(.capsule)
                .foregroundStyle(.primary)
            }
            .padding()
            
            Spacer()
        }
        .padding(.top, 20)
    }

    /// Toggles the selection state of an item.
    /// - Parameter item: The item to toggle in the selection set.
    private func toggleSelection(of item: MultipleSelectionItem<T>) {
        if selectedItems.contains(item) {
            selectedItems.remove(item)
        } else {
            selectedItems.insert(item)
        }
    }
}

/// A row view representing a selectable item with a checkmark if selected.
struct MultipleSelectionRow: View {
    /// The display title of the row.
    let title: String
    
    /// Whether the row is currently selected.
    let isSelected: Bool
    
    /// Action to perform when the row is tapped.
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? .green1 : .gray)
            }
            .padding(20)
            .background(isSelected ? Color.gray.opacity(0.2) : Color.clear)
            .listRowInsets(EdgeInsets())
        }
    }
}


#Preview {
    MultipleSelectionView(items: Category.allCases.map{ MultipleSelectionItem(title: $0.rawValue, item: $0)}, title: "Expense Category") { _ in }
}
