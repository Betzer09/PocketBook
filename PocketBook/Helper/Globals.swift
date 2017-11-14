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

// MARK: - Global Enums
enum TimeFrame: String {
    case pastYear = "Past Year"
    case yearToDate = "Year to Current Date"
    case lastMonth = "Last Month"
    case thisMonth = "This Month"
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
