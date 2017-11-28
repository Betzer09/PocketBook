//
//  Globals.swift
//  PocketBook
//
//  Created by Michael Meyers on 11/14/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation

// MARK: - Global Vars
let calendar = Calendar.autoupdatingCurrent

enum TimeFrame: String {
    case all = "All"
    case thisMonth = "This Month"
    case lastMonth = "Last Month"
    case yearToDate = "Year to Current Date"
    case pastYear = "Past Year"
}

enum TransactionType: String {
    case income = "Income"
    case expense = "Expense"
    case removeIncome = "removeIncome"
    case removeExpense = "removeExpense"
    case plannedExpense = "plannedExpense"
    case all = "All"
}

enum DateHelper {
    // WHAT IS THIS AND WHAT DOES IT DO?
    static var currentDate: Date? {
        let calendar = Calendar.current
        let now = Date()
        return calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now)
    }
}

enum AccountType: String {
    case Checking = "Checking"
    case Saving = "Saving"
    case Credit = "Credit"
}

enum SegmentedControlType: String {
    case all = "All"
    case income = "Income"
    case expense = "Expense"
    case deposit = "Deposit"
    case withdraw = "Withdraw"
    case complete = "Complete"
    case checking = "Checking"
    case saving = "Savings"
    case credit = "Credit"
}

enum monthsOfYear: Int {
    case January = 1
    case February = 2
    case March = 3
    case April = 4
    case May = 5
    case June = 6
    case July = 7
    case August = 8
    case September = 9
    case October = 10
    case November = 11
    case December = 12
}

// MARK: - Global Arrays
let monthsOfTheYear: [String] = [
    "Jan",
    "Feb",
    "Mar",
    "April",
    "May",
    "June",
    "July",
    "Aug",
    "Sept",
    "Oct",
    "Nov",
    "Dec"
]

let weeksOfTheMonth: [String] = [
    "Week 1",
    "Week 2",
    "Week 3",
    "Week 4+"
]
