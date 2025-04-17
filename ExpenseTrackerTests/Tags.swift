//
//  Tags.swift
//  ExpenseTrackerTests
//
//  Created by Pallab Maiti on 17/04/25.
//

import Testing

extension Tag {
    enum expense {}
    enum income {}
}

extension Tag.expense {
    @Tag static var add: Tag
    @Tag static var delete: Tag
    @Tag static var update: Tag
    @Tag static var fetch: Tag
}

extension Tag.income {
    @Tag static var add: Tag
    @Tag static var delete: Tag
    @Tag static var update: Tag
    @Tag static var fetch: Tag
}
