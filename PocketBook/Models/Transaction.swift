//
//  Transaction.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/7/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation
import CloudKit

enum TransactionType: String {
    case Income = "Income"
    case Expense = "Expense"
}

struct Transaction {
    
    // MARK: - Keys
    static let recordType = "Transaction"
    static let dateKey = "date"
    static let budgetKey = "budget"
    static let payeeKey = "payee"
    static let transactionTypeKey = "transaction"
    static let amountKey = "amount"
    static let accountKey = "account"
    
    // MARK: - Properties
    let date: Date
    let budget: String
    let payee: String // Where the money is going
    let transactionType: String
    let amount: Double
    let account: String
    
    init(date: Date, budget: String, payee: String, transactionType: TransactionType.RawValue, amount: Double, account: String) {
        self.date = date
        self.budget = budget
        self.payee = payee
        self.transactionType = transactionType
        self.amount = amount
        self.account = account
    }
    
    // MARK: - cloudKitRecord PUT
    var cloudKitRecord: CKRecord {
        let record = CKRecord(recordType: Transaction.recordType)
        
        record.setValue(date, forKey: Transaction.dateKey)
        record.setValue(budget, forKey: Transaction.budgetKey)
        record.setValue(payee, forKey: Transaction.payeeKey)
        record.setValue(transactionType, forKey: Transaction.transactionTypeKey)
        record.setValue(amount, forKey: Transaction.amountKey)
        record.setValue(account, forKey: Transaction.accountKey)
        
        return record
    }
    
    // MARK: - Failiable Initalizer for cloudKit
    init?(cloudKitRecord: CKRecord) {
        guard let date = cloudKitRecord[Transaction.dateKey] as? Date,
            let budget = cloudKitRecord[Transaction.budgetKey] as? String,
            let payee = cloudKitRecord[Transaction.payeeKey] as? String,
            let transactionType = cloudKitRecord[Transaction.transactionTypeKey] as? String,
            let amount = cloudKitRecord[Transaction.amountKey] as? Double,
            let account = cloudKitRecord[Transaction.accountKey] as? String else {return nil}
        
        self.date = date
        self.budget = budget
        self.payee = payee
        self.transactionType = transactionType
        self.amount = amount
        self.account = account
    }
    
}
