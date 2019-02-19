//
//  PlannedExpense.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/7/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation
import CloudKit

class PlannedExpense: Equatable {
    
    static func ==(lhs: PlannedExpense, rhs: PlannedExpense) -> Bool {
        return lhs.account == rhs.account && lhs.dueDate == rhs.dueDate && lhs.name == rhs.name && lhs.goalAmount == rhs.goalAmount
    }
    
    // MARK: - Properties
    var recordID: CKRecord.ID
    var name: String
    var account: String
    var dueDate: Date
    var goalAmount: Double
    /// initial amount Plus the income for the planned expense -> income dictionary
    var totalDeposited: Double
    var monthlyTotals: [Double] = []
    
    // this is a special kind of transaction
    let transactionType: TransactionType = .plannedExpense
    
    // MARK: - Init
    init(name: String, account: String, dueDate: Date, goalAmount: Double, totalDeposited: Double) {
        
        self.name = name
        self.account = account
        self.dueDate = dueDate
        self.goalAmount = goalAmount
        self.totalDeposited = totalDeposited
        self.recordID = CKRecord.ID(recordName: UUID().uuidString)
        
    }
    
    // MARK: - cloudKitRecord PUT
    
    var cloudKitRecord: CKRecord {
        let record = CKRecord(recordType: Keys.recordPlannedExpenseType, recordID: recordID)
        
        record.setValue(name, forKey: Keys.plannedExpenseNameKey)
        record.setValue(account, forKey: Keys.accountPlannedExpenseKey)
        record.setValue(dueDate, forKey: Keys.dueDateKey)
        record.setValue(goalAmount, forKey: Keys.goalAmountKey)
        record.setValue(totalDeposited, forKey: Keys.totalDepositedKey)
        
        return record
        
    }
    
    // MARK: - failable Initializer cloudKit
    
    init?(cloudKitRecord: CKRecord) {
        guard let name = cloudKitRecord[Keys.plannedExpenseNameKey] as? String,
            let account = cloudKitRecord[Keys.accountPlannedExpenseKey] as? String,
            let dueDate = cloudKitRecord[Keys.dueDateKey] as? Date,
            let goalAmount = cloudKitRecord[Keys.goalAmountKey] as? Double,
            let totalDeposited = cloudKitRecord[Keys.totalDepositedKey] as? Double else {return nil}
        
        self.name = name
        self.account = account
        self.dueDate = dueDate
        self.goalAmount = goalAmount
        self.totalDeposited = totalDeposited
        self.recordID = cloudKitRecord.recordID
    }
}
