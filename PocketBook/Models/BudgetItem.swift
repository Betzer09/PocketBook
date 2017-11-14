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
    
    // MARK: - Keys
    static let recordType = "BudgetItem"
    static let spentTotalKey = "spentTotal"
    static let allottedAmountKey = "allottedAmount"
    static let totalAllottedKey = "totalAllotted"
    static let nameKey = "name"
    
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
        let record = CKRecord(recordType: BudgetItem.recordType, recordID: recordID)
        
        record.setValue(spentTotal, forKey: BudgetItem.spentTotalKey)
        record.setValue(name, forKey: BudgetItem.nameKey)
        record.setValue(allottedAmount, forKey: BudgetItem.allottedAmountKey)
        record.setValue(totalAllotted, forKey: BudgetItem.totalAllottedKey)
        
        return record
    }
    
    // MARK: - Failiable Initializer for cloudKit
    init?(cloudKitRecord: CKRecord) {
        guard let name = cloudKitRecord[BudgetItem.nameKey] as? String,
            let spentTotal = cloudKitRecord[BudgetItem.spentTotalKey] as? Double,
            let allottedAmount = cloudKitRecord[BudgetItem.allottedAmountKey] as? Double,
            let totalAllotted = cloudKitRecord[BudgetItem.totalAllottedKey] as? Double else {return nil}
        
        self.name = name
        self.spentTotal = spentTotal
        self.allottedAmount = allottedAmount
        self.totalAllotted = totalAllotted
        self.recordID = cloudKitRecord.recordID
    }
    
}
