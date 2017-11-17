//
//  PlannedExpense.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/7/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation
import CloudKit

class PlannedExpense {
    
    // MARK: - Properties
    var recordID: CKRecordID
    var name: String
    var account: String
    var dueDate: Date
    var initialAmount: Double
    var goalAmount: Double
    var amountDeposited: Double
    var amountWithdrawn: Double
    /// initial amount Plus the income for the planned expense -> income dictionary
    var totalSaved: Double?
    var monthlyTotals: [Double] = []
    
    // MARK: - Init
    init(name: String, account: String, dueDate: Date, initialAmount: Double, goalAmount: Double, amountDeposited: Double = 0, amountWithdrawn: Double = 0) {
        
        self.name = name
        self.account = account
        self.dueDate = dueDate
        self.initialAmount = initialAmount
        self.goalAmount = goalAmount
        self.amountDeposited = amountDeposited
        self.amountWithdrawn = amountWithdrawn
        self.totalSaved = initialAmount 
        self.recordID = CKRecordID(recordName: UUID().uuidString)
        
    }
    
    // MARK: - cloudKitRecord PUT
    
    var cloudKitRecord: CKRecord {
        let record = CKRecord(recordType: Keys.recordPlannedExpenseType, recordID: recordID)
        
        record.setValue(name, forKey: Keys.plannedExpenseNameKey)
        record.setValue(account, forKey: Keys.accountPlannedExpenseKey)
        record.setValue(dueDate, forKey: Keys.dueDateKey)
        record.setValue(initialAmount, forKey: Keys.initialAmountKey)
        record.setValue(goalAmount, forKey: Keys.goalAmountKey)
        record.setValue(amountDeposited, forKey: Keys.amountDepositedKey)
        record.setValue(amountWithdrawn, forKey: Keys.amountWithdrawnKey)
        record.setValue(totalSaved, forKey: Keys.totalSavedKey)
        
        return record
        
    }
    
    // MARK: - failable Initializer cloudKit
    
    init?(cloudKitRecord: CKRecord) {
        guard let name = cloudKitRecord[Keys.plannedExpenseNameKey] as? String,
            let account = cloudKitRecord[Keys.accountPlannedExpenseKey] as? String,
            let dueDate = cloudKitRecord[Keys.dueDateKey] as? Date,
            let initialAmount = cloudKitRecord[Keys.initialAmountKey] as? Double,
            let goalAmount = cloudKitRecord[Keys.goalAmountKey] as? Double,
            let amountDeposited = cloudKitRecord[Keys.amountDepositedKey] as? Double,
            let amountWithdrawn = cloudKitRecord[Keys.amountWithdrawnKey] as? Double,
            let totalSaved = cloudKitRecord[Keys.totalSavedKey] as? Double else {return nil}
        
        self.name = name
        self.account = account
        self.dueDate = dueDate
        self.initialAmount = initialAmount
        self.goalAmount = goalAmount
        self.amountDeposited = amountDeposited
        self.amountWithdrawn = amountWithdrawn
        self.totalSaved = totalSaved
        self.recordID = cloudKitRecord.recordID
    }
}
