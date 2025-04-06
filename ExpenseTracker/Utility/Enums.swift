//
//  Enums.swift
//  ExpenseTracker
//
//  Created by Pallab Maiti on 02/04/25.
//

import Foundation

/// Represents the available options for sorting data (such as expenses or incomes)
/// in the expense tracker application.
///
/// Each case corresponds to a different attribute by which the user can sort entries.
/// These sorting preferences help users organize their financial records based on relevance.
enum SortingOption: String, CaseIterable {
    
    /// Sort by the date of the transaction.
    ///
    /// - Use Case: Display transactions in chronological or reverse-chronological order.
    /// - Often used in reports, history views, or trends over time.
    case date = "Date"
    
    /// Sort by the monetary amount of the transaction.
    ///
    /// - Use Case: Prioritize large or small transactions.
    /// - Useful for identifying high-spend categories or filtering by impact.
    case amount = "Amount"
    
    /// Sort alphabetically by the name or title associated with the transaction.
    ///
    /// - Use Case: Helpful in quickly locating a specific entry or grouping similar entries (e.g., merchant names, categories).
    case name = "Name"
    
    /// A computed property that provides an appropriate SF Symbol system image name for each sort option.
    ///
    /// These icons can be used alongside text labels in the UI to provide a more intuitive and visually
    /// engaging interface, such as in segmented controls or filter dropdowns.
    var systemImageName: String {
        switch self {
        case .date:
            return "calendar"
        case .amount:
            return "dollarsign"
        case .name:
            return "a.circle.fill"
        }
    }
}

/// An enumeration representing the direction of sorting used in various parts of the expense tracker app.
///
/// `Ordering` is used in sorting lists such as transactions, incomes, or expenses based on selected criteria
/// (e.g., date or amount). This improves data visualization and enhances user control over list organization.
enum Ordering {
    
    /// Ascending order.
    ///
    /// - For dates: earlier dates appear first (e.g., Jan → Dec).
    /// - For numbers: lower values appear first (e.g., 100 → 1000).
    /// - Typical use cases: chronological views, trend analysis, budgeting over time.
    case ascending

    /// Descending order.
    ///
    /// - For dates: later dates appear first (e.g., Dec → Jan).
    /// - For numbers: higher values appear first (e.g., 1000 → 100).
    /// - Typical use cases: seeing most recent transactions or highest expenses first.
    case descending
    
    /// A computed property that provides an appropriate SF Symbol system image name for each ordering option.
    ///
    /// These icons can be used alongside text labels in the UI to provide a more intuitive and visually
    /// engaging interface, such as in segmented controls or filter dropdowns.
    var systemImageName: String {
        switch self {
        case .ascending:
            return "arrowtriangle.up.fill"
        case .descending:
            return "arrowtriangle.down.fill"
        }
    }
}

/// An enumeration representing the different sources of income in the expense tracker application.
///
/// Categorizing income sources helps users track where their money is coming from,
/// providing better visibility and reporting for budgeting or financial analysis.
///
/// This enum conforms to:
/// - `String`: Each case has a user-friendly raw string value for display and persistence.
/// - `CaseIterable`: Enables looping over all values (e.g., for UI pickers or filters).
/// - `Codable`: Supports encoding/decoding when saving or loading data from a database or API.
enum Source: String, CaseIterable, Codable {
    
    /// Income from full-time, part-time, or contractual employment.
    /// Examples: monthly salary, bonuses, or wages.
    case salary = "Salary"
    
    /// Income generated from interest-bearing accounts or investments.
    /// Examples: fixed deposits, savings accounts, or bonds.
    case interest = "Interest"
    
    /// Income earned from renting out property or assets.
    /// Examples: rental properties, equipment leasing, or subletting.
    case rental = "Rental"
    
    /// Income generated through business activities or self-employment.
    /// Examples: freelancing, entrepreneurship, consulting, or side hustles.
    case business = "Business"
    
    /// Any other type of income not classified above.
    /// Examples: gifts, lottery winnings, inheritance, or one-time gains.
    case other = "Other"
}

/// An enumeration representing different categories of expenses in the expense tracker application.
///
/// Each case corresponds to a specific type of expense that users can assign to their transactions.
/// Categorizing expenses helps users gain insights into their spending habits and enables better budgeting and financial planning.
///
/// This enum conforms to:
/// - `String` raw values for easy display and storage.
/// - `CaseIterable` to allow iteration over all available categories (e.g., for populating dropdowns or pickers).
/// - `Codable` to support encoding and decoding when saving or loading from persistent storage.
enum Category: String, CaseIterable, Codable {
    
    /// Represents food-related expenses such as groceries, dining out, takeout, or cafes.
    case food = "Food"
    
    /// Represents expenses related to entertainment and leisure,
    /// including movies, subscriptions (e.g., Netflix), games, events, or hobbies.
    case entertainment = "Entertainment"
    
    /// Represents travel-related expenses including transportation,
    /// flights, fuel, public transit, hotel stays, or road trips.
    case travel = "Travel"
    
    /// Represents shopping expenses for clothing, accessories,
    /// electronics, gifts, or non-essential purchases.
    case shopping = "Shopping"
    
    /// Represents health-related expenses such as medications,
    /// doctor visits, fitness memberships, health insurance, or therapy.
    case health = "Health"
    
    /// A fallback category for any expense that doesn't fit into the predefined categories.
    /// Useful for miscellaneous or one-off purchases.
    case other = "Other"
}

/// An enumeration representing various filter options available for organizing or narrowing down transactions
/// in the expense tracker application. Each case corresponds to a distinct criterion by which the user can
/// filter their data, such as by date, amount, income source, or expense category.
///
/// This enum conforms to `RawRepresentable` (via `String`) for display purposes,
/// and `CaseIterable` to allow easy iteration over all possible filter types—for example, in UI menus or pickers.
enum FilterOption: String, CaseIterable {
    
    /// Filters transactions based on their associated date.
    ///
    /// This allows users to view entries from a specific day, month, or year,
    /// and is useful when reviewing daily, monthly, or yearly income and expenses.
    case date = "Date"
    
    /// Filters transactions based on the monetary value of the transaction.
    ///
    /// This is useful when analyzing high or low-value transactions, or
    /// comparing spending vs earnings by amount.
    case amount = "Amount"
    
    /// Filters income entries by their source, such as salary, business, or rental income.
    ///
    /// This helps users understand which income streams contribute most to their earnings.
    case source = "Income Source"
    
    /// Filters expenses by their category, such as food, travel, or utilities.
    ///
    /// Useful for budgeting and analyzing where the user spends the most money.
    case category = "Expense Category"
}

enum AmountRange: CaseIterable {
    case lessThanTwoHundred
    case twoHundredToFiveHundred
    case fiveHundredToTwoThousand
    case moreThanTwoThousand
    
    var title: String {
        switch self {
        case .lessThanTwoHundred:
            return "Up to \(Locale.current.currencySymbol ?? "$")200"
        case .twoHundredToFiveHundred:
            return "\(Locale.current.currencySymbol ?? "$")200 - \(Locale.current.currencySymbol ?? "$")500"
        case .fiveHundredToTwoThousand:
            return "\(Locale.current.currencySymbol ?? "$")500 - \(Locale.current.currencySymbol ?? "$")2000"
        case .moreThanTwoThousand:
            return "Above \(Locale.current.currencySymbol ?? "$")2000"
        }
    }
    
    var range: ClosedRange<Double> {
        switch self {
        case .lessThanTwoHundred:
            return 0.0...200.0
        case .twoHundredToFiveHundred:
            return 200.0...500.0
        case .fiveHundredToTwoThousand:
            return 500.0...2000.0
        case .moreThanTwoThousand:
            return 2000.0...9999999.0
        }
    }
}
