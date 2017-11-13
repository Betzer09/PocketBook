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
    
    // MARK: - Keys
    static let recordType = "PlannedExpense"
    static let nameKey = "name"
    static let accountKey = "account"
    static let dueDateKey = "dueDate"
    static let initialAmountKey = "initialAmount"
    static let goalAmountKey = "goalAmount"
    static let totalSavedKey = "totalSaved"
    
    // MARK: - Properties
    var recordID: CKRecordID
    var name: String
    var account: String
    var dueDate: Date
    var initialAmount: Double
    var goalAmount: Double
    var totalSaved: Double {
        
        
        
        
        // initial amount Plus the income for the planned expense -> income dictionary
        // TODO: Create a income dictionary
        return initialAmount + 0
    }
    
    // MARK: - Init
    init(name: String, account: String, dueDate: Date, initialAmount: Double, goalAmount: Double) {
        
        self.name = name
        self.account = account
        self.dueDate = dueDate
        self.initialAmount = initialAmount
        self.goalAmount = goalAmount
        self.recordID = CKRecordID(recordName: UUID().uuidString)
        
    }
    
    // MARK: - cloudKitRecord PUT
    
    var cloudKitRecord: CKRecord {
        let record = CKRecord(recordType: PlannedExpense.recordType, recordID: recordID)
        
        record.setValue(name, forKey: PlannedExpense.nameKey)
        record.setValue(account, forKey: PlannedExpense.accountKey)
        record.setValue(dueDate, forKey: PlannedExpense.dueDateKey)
        record.setValue(initialAmount, forKey: PlannedExpense.initialAmountKey)
        record.setValue(goalAmount, forKey: PlannedExpense.goalAmountKey)
        record.setValue(totalSaved, forKey: PlannedExpense.totalSavedKey)
        
        return record
        
    }
    
    // MARK: - failable Initializer cloudKit
    
    init?(cloudKitRecord: CKRecord) {
        guard let name = cloudKitRecord[PlannedExpense.nameKey] as? String,
            let account = cloudKitRecord[PlannedExpense.accountKey] as? String,
            let dueDate = cloudKitRecord[PlannedExpense.dueDateKey] as? Date,
            let initialAmount = cloudKitRecord[PlannedExpense.initialAmountKey] as? Double,
            let goalAmount = cloudKitRecord[PlannedExpense.goalAmountKey] as? Double,
            let totalSaved = cloudKitRecord[PlannedExpense.totalSavedKey] as? Double else {return nil}
        
        
        self.name = name
        self.account = account
        self.dueDate = dueDate
        self.initialAmount = initialAmount
        self.goalAmount = goalAmount
        self.totalSaved = totalSaved
        self.recordID = cloudKitRecord.recordID
    }
    
}
