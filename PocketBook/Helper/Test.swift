//
//  Test.swift
//  PocketBook
//
//  Created by Michael Meyers on 11/9/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation

// TESTING
let categories: [String] = [
    "Food",
    "Gas",
    "Clothes",
    "Household",
    "CarPayment",
    "CellPhone",
    "TV/Internet",
    "Emergency",
    "Hospital Bills"
]

func createTransaction() {
    let types = ["Expense", "Income"]
    guard let date = generateRandomDate(daysBack: Int(arc4random_uniform(UInt32(365)))) else {return}
    let categories = getAllBudgetItemNames()
    let category = categories[Int(arc4random_uniform(UInt32(categories.count)))]
    let payee = "Walmart"
    let transActionType = types[Int(arc4random_uniform(1))]
    let amount = Double(arc4random_uniform(UInt32(200)))
    let accounts = AccountController.shared.accounts
    let account = accounts[Int(arc4random_uniform(UInt32(accounts.count)))]
    let name = account.name
    
    TransactionController.shared.createTransactionWith(date: date, category: category, payee: payee, transactionType: transActionType, amount: amount, account: name) { (_) in
        // TODO: TELL AUSTIN TO FIX THIS
    }
}

func loop(number: Int, transform: () -> ()) {
    for _ in 1...number{
        transform()
    }
}

func generateRandomDate(daysBack: Int)-> Date?{
    let day = arc4random_uniform(UInt32(daysBack))+1
    let hour = arc4random_uniform(23)
    let minute = arc4random_uniform(59)
    let date = Date(dateString: "2016-01-01")
    let today = Date(timeInterval: 0, since: date)
    let gregorian  = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
    var offsetComponents = DateComponents()
    offsetComponents.day = Int(day - 1)
    offsetComponents.hour = Int(hour)
    offsetComponents.minute = Int(minute)

    let randomDate = gregorian?.date(byAdding: offsetComponents, to: today, options: .init(rawValue: 0) )
    return randomDate
}

func changeAllYearByOne(transactions: [Transaction]) {
    for transaction in transactions {
        let date = transaction.date
        let year = dateComponentYear(date: date)
        let day = dateComponentDay(date: date)
        let month = dateComponentMonth(date: date)
        let lastYear = year - 1
        let dateString = "\(lastYear)-\(month)-\(day)"
        let newDate = Date(dateString: dateString)
        transaction.date = newDate
        TransactionController.shared.updateTransactionWith(transaction: transaction, date: transaction.date, category: transaction.category, payee: transaction.payee, transactionType: transaction.transactionType, amount: transaction.amount, account: transaction.account, completion: { (_) in
            //TODO: TELL AUSTION TO FIX THIS
        })
    }
}

//    let transactions = [
//        Transaction(date: Date(), category: "Food", payee: "Wal-Mart", transactionType: "expense", amount: 50.00, account: "Savings"),
//        Transaction(date: Date(dateString: "2017-10-20"), category: "Gas", payee: "Chevron", transactionType: "expense", amount: 19.58, account: "Checking"),
//        Transaction(date: Date(dateString: "2016-12-20"), category: "Clothes", payee: "Target", transactionType: "expense", amount: 400.30, account: "Credit Card"),
//        Transaction(date: Date(dateString: "2017-01-01"), category: "CellPhone", payee: "Sprint", transactionType: "expense", amount: 99.00, account: "Checking"),
//        Transaction(date: Date(dateString: "2017-10-15"), category: "Food", payee: "Smiths", transactionType: "expense", amount: 47.39, account: "Checking"),
//        Transaction(date: Date(dateString: "2017-11-02"), category: "Food", payee: "Smiths", transactionType: "expense", amount: 28.34, account: "Checking")
//    ]

//    let transactions = loop(number: 30)


extension Date
{
    init(dateString:String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        let d = dateStringFormatter.date(from: dateString)!
        self.init(timeInterval:0, since:d)
    }
}
