//
//  Enums.swift
//  PocketBook
//
//  Created by Michael Meyers on 11/8/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation

enum TimeFrame: String {
    case pastYear = "Past Year"
    case yearToDate = "Year to Current Date"
    case lastMonth = "Last Month"
    case thisMonth = "This Month"
}

enum TransactionType: String {
    case income = "Income"
    case expense = "Expense"
    case all = "All"
}
