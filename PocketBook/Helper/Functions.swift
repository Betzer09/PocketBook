//
//  Functions.swift
//  PocketBook
//
//  Created by Michael Meyers on 11/13/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation
import UIKit

let view = UIView()

// MARK: - Alert function
func presentSimpleAlert(controllerToPresentAlert vc: UIViewController, title: String, message: String) {
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    
    alert.addAction(dismissAction)
    
    vc.present(alert, animated: true, completion: nil)
}

// MARK: - DateComponents Functions
func dateComponentMonth(date: Date) -> Int {
    let dateComponents = calendar.dateComponents([.month], from: date)
    guard let month = dateComponents.month else {return 0}
    return month
}

func dateComponentYear(date: Date) -> Int {
    let dateComponents = calendar.dateComponents([.year], from: date)
    guard let year = dateComponents.year else {return 0}
    return year
}

// MARK: - Filter Functions
func filterByTimeFrame(withTimeVariable timeFrame: String, forThisArray transactions: [Transaction]) -> [Transaction] {
    
    var internalFilteredTransactions: [Transaction] = []
    for transaction in transactions {
        let currentMonth = dateComponentMonth(date: Date())
        let currentYear = dateComponentYear(date: Date())
        let transactionMonth = dateComponentMonth(date: transaction.date)
        let transactionYear = dateComponentYear(date: transaction.date)
        
        switch timeFrame {
        case TimeFrame.pastYear.rawValue:
            if transactionYear == currentYear {
                if transactionMonth <= currentMonth {
                    internalFilteredTransactions.append(transaction)
                }
            }
            if transactionYear == (currentYear - 1) {
                if transactionMonth > currentMonth {
                    internalFilteredTransactions.append(transaction)
                }
            }
        case TimeFrame.yearToDate.rawValue:
            if transactionYear == currentYear {
                if transactionMonth <= currentMonth {
                    internalFilteredTransactions.append(transaction)
                }
            }
        case TimeFrame.lastMonth.rawValue:
            var lastMonth: Int
            if currentMonth == 1 {
                lastMonth = 12
            } else {
                lastMonth = currentMonth - 1
            }
            if transactionMonth == (lastMonth) {
                internalFilteredTransactions.append(transaction)
            }
        case TimeFrame.thisMonth.rawValue:
            if transactionYear == currentYear {
                if transactionMonth == currentMonth {
                    internalFilteredTransactions.append(transaction)
                }
            }
        default:
            internalFilteredTransactions = transactions
        }
        
    }
    return internalFilteredTransactions
}

func filterByCategoryIntoDictionary(forThisArray transactions:[Transaction]) -> [String: Double] {
    var internalFilteredTransactionsDictionary: [String: Double] = [:]
    let categories = getAllBudgetItemNames()
    for category in categories {
        var categoryTotal = 0.0
        for transaction in transactions {
            if transaction.category == category {
                categoryTotal += transaction.amount
            }
        }
        internalFilteredTransactionsDictionary[category] = categoryTotal
    }
    return internalFilteredTransactionsDictionary
    
}

func filterByCategoryIntoArray(forCategory name: String, forThisArray transactions: [Transaction]) -> [Transaction] {
    var internalFilteredTransactions: [Transaction] = []
    
    for transaction in transactions {
        if transaction.category == name {
            internalFilteredTransactions.append(transaction)
        }
    }
    return internalFilteredTransactions
}


// MARK: - Fetch Functions
func getAllBudgetItemNames() -> [String] {
    let budgetItems = BudgetItemController.shared.budgetItems
    let namesArray = budgetItems.map({ $0.name })
    return namesArray
}


// MARK: - Calculate Functions
func calculateMonthTotals(transactions: [Transaction], month: Int) -> [Double] {
    var localTotals: [Double] = []
    var week1Total: Double = 0
    var week2Total: Double = 0
    var week3Total: Double = 0
    var week4Total: Double = 0
    for transaction in transactions {
        let calendarDate = calendar.dateComponents([.month, .year, .day], from: transaction.date)
        if month == calendarDate.month {
            guard let day = calendarDate.day else {return []}
            if day <= 7 {
                week1Total += transaction.amount
            }
            if day <= 14 {
                week2Total += transaction.amount
            }
            if day <= 21 {
                week3Total += transaction.amount
            }
            if day > 21 {
                week4Total += transaction.amount
            }
        }
    }
    localTotals.append(week1Total)
    localTotals.append(week2Total)
    localTotals.append(week3Total)
    localTotals.append(week4Total)
    return localTotals
}

func calculatePercentValue(withBudgetItemSpentTotal budgetItemSpentTotal: Double, totalSpent: Double, maxY: CGFloat) -> CGFloat {
    let bugetItemCGFloat = CGFloat(budgetItemSpentTotal)
    let totalSpentCGFloat = CGFloat(totalSpent)
    return (bugetItemCGFloat/totalSpentCGFloat) * maxY
}

func calculateDistanceOfEachXCatagory(inView xView: UIView, withDivisor divisor: Int) -> CGFloat {
    let segmentDivision = CGFloat(divisor + 2)
    let segment = (xView.bounds.maxX / segmentDivision)
    return segment
}

