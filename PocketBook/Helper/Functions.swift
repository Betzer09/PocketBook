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

// MARK: - Date Functions
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

func dateComponentDay(date: Date) -> Int {
    let dateComponents = calendar.dateComponents([.day], from: date)
    guard let day = dateComponents.day else {return 0}
    return day
}

//DATE FORMATTING - Get rid of only if able to change date formatting?
func returnFormattedDate(date: Date) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM yyyy"
    let strDate = dateFormatter.string(from: date)
    let formattedDate: Date? = dateFormatter.date(from: strDate)
    return formattedDate ?? Date()
}

/// This function return a date as a String in the format "dd-MM-yyyy"
func returnFormattedDateString(date: Date) -> String {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM dd, yyyy"
    let strDate = dateFormatter.string(from: date)
    return strDate
    
}

// MARK: - Conversion Functions
func convertStringToTransactionType (string: String) -> TransactionType {
    var transactionType: TransactionType
    switch string {
    case TransactionType.income.rawValue:
        transactionType = TransactionType.income
    case TransactionType.expense.rawValue:
        transactionType = TransactionType.expense
    case TransactionType.removeExpense.rawValue:
        transactionType = TransactionType.removeExpense
    case TransactionType.removeIncome.rawValue:
        transactionType = TransactionType.removeIncome
    case TransactionType.all.rawValue:
        transactionType = TransactionType.all
    default:
        fatalError("String did not match any raw Value of the Enum")
    }
    return transactionType
}

/// This function filters out "$" and "," from textfields
func removeCharactersFromTextField(_ textField: UITextField?) -> String {
    
    var finalString: String = ""
    guard let string = textField?.text else { return "" }
    let stringOne = string.replacingOccurrences(of: ",", with: "")
    let stringTwo = stringOne.replacingOccurrences(of: "$", with: "")
    finalString = stringTwo
    return finalString
}

/// Formats string to a double 
func formatNumberToString(fromDouble double: Double) -> String {
    
    var formattedNumber: String = ""
    let nsNumber = NSNumber(value: double)
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 2;
    if let number = formatter.string(from: nsNumber) {
        formattedNumber = number
    }
    return formattedNumber
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

func filterByAccountIntoArray(forCategory name: String, forThisArray transactions: [Transaction]) -> [Transaction] {
    var internalFilteredTransactions: [Transaction] = []
    guard name != "All" else {
        internalFilteredTransactions = transactions
        return internalFilteredTransactions
    }
    
    for transaction in transactions {
        if transaction.account == name {
            internalFilteredTransactions.append(transaction)
        }
    }
    return internalFilteredTransactions
}

func filterByCategoryIntoArray(forCategory name: String, forThisArray transactions: [Transaction]) -> [Transaction] {
    var internalFilteredTransactions: [Transaction] = []
    guard name != "All" else {
        internalFilteredTransactions = transactions
        return internalFilteredTransactions
    }
    
    for transaction in transactions {
        if transaction.category == name {
            internalFilteredTransactions.append(transaction)
        }
    }
    return internalFilteredTransactions
}

func filterByTransactionType(byThisType selectedControl: String, forThisArray transactions: [Transaction]) -> [Transaction] {
    var internalFilteredTransactions: [Transaction] = []
    for transaction in transactions {
        if selectedControl == "All" {
            internalFilteredTransactions = transactions
        } else if transaction.transactionType == selectedControl {
            internalFilteredTransactions.append(transaction)
        }
    }
    return internalFilteredTransactions
}

func checkWhichControlIsPressed(segmentedControl: UISegmentedControl, type1: SegmentedControlType, type2: SegmentedControlType, type3: SegmentedControlType? = nil ) -> String {
    var currentSegmentedControlSelection = ""
    let index = segmentedControl.selectedSegmentIndex
    let title = segmentedControl.titleForSegment(at: index)

    if title == type1.rawValue {
        currentSegmentedControlSelection = type1.rawValue
    }
    if title == type2.rawValue {
        currentSegmentedControlSelection = type2.rawValue
    }
    if let type3 = type3 {
        if title == type3.rawValue {
            currentSegmentedControlSelection = type3.rawValue
        }
    }
    else {
        fatalError("There was not a correct type given in the function.")
    }
    return currentSegmentedControlSelection
}

// MARK: - Fetch Functions
func getAllBudgetItemNames() -> [String] {
    let budgetItems = BudgetItemController.shared.budgetItems
    let namesArray = budgetItems.map({ $0.name })
    return namesArray
}

func getAllPlannedExpenseNames() -> [String] {
    let plannedExpenses = PlannedExpenseController.shared.plannedExpenses
    let namesArray = plannedExpenses.map({ $0.name })
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

func calculateTotalsArrays(fromPlannedExpenses plannedExpenses: [PlannedExpense], matchingCategory category: String) -> [Double] {
    var totals: [Double] = []
    for plannedExpense in plannedExpenses {
        if plannedExpense.name == category {
            totals = plannedExpense.monthlyTotals
        }
    }
    return totals
}



func updateAccountHeader(withname name: String, basedOnArray array: Array<Account>) -> String {
    
    var accountName: String = ""
    let numberOfAccounts = array.count
    if numberOfAccounts == 1 {
        accountName = name
    } else {
        var account = String(name)
        account.insert("s", at: account.endIndex)
        accountName = account
    }
    return accountName
}

func returnFormattedDate(fromdate date: Date) -> String {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    dateFormatter.locale = Locale(identifier: "en_US")
    let date = dateFormatter.string(from: date)
    return date
}

func returnString(fromDate date: Date) -> String {
    var dateString: String = ""
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "LLLL yyyy"
    let string = dateFormatter.string(from: date)
    dateString = string
    return dateString
}

func removeDuplicates(fromArray array: [String]) -> [String] {
    var encountered = Set<String>()
    var result: [String] = []
    for string in array {
        if encountered.contains(string) {
        } else {
            encountered.insert(string)
            result.append(string)
        }
    }
    return result
}


