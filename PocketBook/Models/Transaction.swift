//
//  Transaction.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/7/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation
import CloudKit


class Transaction: Hashable, Equatable { //
    
    // MARK: - Properties
    var date: Date
    var category: String
    var payee: String // Where the money is going
    var transactionType: String
    var amount: Double
    var account: String
    var recordID: CKRecordID
    var hashValue: Int { get {
        return recordID.hashValue
        }
    }
    
    init(date: Date, category: String, payee: String, transactionType: TransactionType.RawValue, amount: Double, account: String) {
        self.date = date
        self.category = category
        self.payee = payee
        self.transactionType = transactionType
        self.amount = amount
        self.account = account
        self.recordID = CKRecordID(recordName: UUID().uuidString)
    }
    
    // MARK: - cloudKitRecord PUT
    var cloudKitRecord: CKRecord {
        let record = CKRecord(recordType: Keys.recordTransactionType, recordID: recordID)
        
        record.setValue(date, forKey: Keys.dateKey)
        record.setValue(category, forKey: Keys.catagoryKey)
        record.setValue(payee, forKey: Keys.payeeKey)
        record.setValue(transactionType, forKey: Keys.transactionTypeKey)
        record.setValue(amount, forKey: Keys.amountKey)
        record.setValue(account, forKey: Keys.accountTransactionKey)
        
        return record
    }
    
    // MARK: - Failiable Initalizer for cloudKit
    init?(cloudKitRecord: CKRecord) {
        guard let date = cloudKitRecord[Keys.dateKey] as? Date,
            let budget = cloudKitRecord[Keys.catagoryKey] as? String,
            let payee = cloudKitRecord[Keys.payeeKey] as? String,
            let transactionType = cloudKitRecord[Keys.transactionTypeKey] as? String,
            let amount = cloudKitRecord[Keys.amountKey] as? Double,
            let account = cloudKitRecord[Keys.accountTransactionKey] as? String else {return nil}
        
        self.date = date
        self.category = budget
        self.payee = payee
        self.transactionType = transactionType
        self.amount = amount
        self.account = account
        self.recordID = cloudKitRecord.recordID
    }
}

// Equatable
func ==(lhs: Transaction, rhs: Transaction) -> Bool {
    return lhs.recordID == rhs.recordID
}
