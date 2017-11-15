//
//  BudgetItem.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/7/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation
import CloudKit

class BudgetItem {
    
    // MARK: - Properties
    let recordID: CKRecordID
    var spentTotal: Double
    var name: String // Category
    
    /// This should only be modified by the user not the developer! If changes need to be made do it to the totalAllotted.
    var allottedAmount: Double
    var totalAllotted: Double?
    
    init(spentTotal: Double, name: String, allottedAmount: Double) {
        self.spentTotal = spentTotal
        self.name = name
        self.allottedAmount = allottedAmount
        self.totalAllotted = allottedAmount
        self.recordID = CKRecordID(recordName: UUID().uuidString)
    }
    
    // MARK: - cloudKitRecord PUT
    var cloudKitRecord: CKRecord {
        let record = CKRecord(recordType: Keys.recordBudgetItemType, recordID: recordID)
        
        record.setValue(spentTotal, forKey: Keys.spentTotalKey)
        record.setValue(name, forKey: Keys.budgetItemNameKey)
        record.setValue(allottedAmount, forKey: Keys.allottedAmountKey)
        record.setValue(totalAllotted, forKey: Keys.totalAllottedKey)
        
        return record
    }
    
    // MARK: - Failiable Initializer for cloudKit
    init?(cloudKitRecord: CKRecord) {
        guard let name = cloudKitRecord[Keys.budgetItemNameKey] as? String,
            let spentTotal = cloudKitRecord[Keys.spentTotalKey] as? Double,
            let allottedAmount = cloudKitRecord[Keys.allottedAmountKey] as? Double,
            let totalAllotted = cloudKitRecord[Keys.totalAllottedKey] as? Double else {return nil}
        
        self.name = name
        self.spentTotal = spentTotal
        self.allottedAmount = allottedAmount
        self.totalAllotted = totalAllotted
        self.recordID = cloudKitRecord.recordID
    }
}
