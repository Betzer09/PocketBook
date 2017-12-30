//
//  Test.swift
//  PocketBook
//
//  Created by Michael Meyers on 11/9/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation

// TESTING
//let categories: [String] = [
//    "Food",
//    "Gas",
//    "Clothes",
//    "Household",
//    "CarPayment",
//    "CellPhone",
//    "TV/Internet",
//    "Emergency",
//    "Hospital Bills"
//]

//func createTransaction() -> Transaction? {
//    guard let date = generateRandomDate(daysBack: Int(arc4random_uniform(UInt32(365)))) else {return nil}
//    let category = categories[Int(arc4random_uniform(UInt32(categories.count)))]
//    let payee = "Walmart"
//    let transActionType = "Expense"
//    let amount = Double(arc4random_uniform(UInt32(200)))
//    let account = "Banking"
//
//    let transaction = Transaction(date: date, category: category, payee: payee, transactionType: transActionType, amount: amount, account: account)
//    return transaction
//}

//func loop(number: Int) -> [Transaction]{
//    var array: [Transaction] = []
//    for _ in 1...number{
//        guard let transaction = createTransaction() else {return array}
//        array.append(transaction)
//    }
//    return array
//}

//func generateRandomDate(daysBack: Int)-> Date?{
//    let day = arc4random_uniform(UInt32(daysBack))+1
//    let hour = arc4random_uniform(23)
//    let minute = arc4random_uniform(59)
//    
//    let today = Date(timeIntervalSinceNow: 0)
//    let gregorian  = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
//    var offsetComponents = DateComponents()
//    offsetComponents.day = Int(day - 1)
//    offsetComponents.hour = Int(hour)
//    offsetComponents.minute = Int(minute)
//    
//    let randomDate = gregorian?.date(byAdding: offsetComponents, to: today, options: .init(rawValue: 0) )
//    return randomDate
//}

// FOR TESTING
//    let transactions = [
//        Transaction(date: Date(), category: "Food", payee: "Wal-Mart", transactionType: "expense", amount: 50.00, account: "Savings"),
//        Transaction(date: Date(dateString: "2017-10-20"), category: "Gas", payee: "Chevron", transactionType: "expense", amount: 19.58, account: "Checking"),
//        Transaction(date: Date(dateString: "2016-12-20"), category: "Clothes", payee: "Target", transactionType: "expense", amount: 400.30, account: "Credit Card"),
//        Transaction(date: Date(dateString: "2017-01-01"), category: "CellPhone", payee: "Sprint", transactionType: "expense", amount: 99.00, account: "Checking"),
//        Transaction(date: Date(dateString: "2017-10-15"), category: "Food", payee: "Smiths", transactionType: "expense", amount: 47.39, account: "Checking"),
//        Transaction(date: Date(dateString: "2017-11-02"), category: "Food", payee: "Smiths", transactionType: "expense", amount: 28.34, account: "Checking")
//    ]

//    let transactions = loop(number: 30)
//
//    let categories: [String] = [
//        "Food",
//        "Gas",
//        "Clothes",
//        "Household",
//        "CarPayment",
//        "CellPhone",
//        "TV/Internet",
//        "Emergency",
//        "Hospital Bills",
//        "Cats",
//        "Dogs",
//        "Parrot",
//        "Avacado",
//        "Julius"
//    ]

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
