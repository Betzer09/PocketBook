//
//  Users.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/7/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation
import CloudKit

class User {
    
    // MARK: - Properties
    var projectedIncome: Double
    let recordID: CKRecord.ID
    var hasResetMonthlyBudget: Bool?
    
    init(projectedIncome: Double) {
        self.projectedIncome = projectedIncome
        self.recordID = CKRecord.ID(recordName: UUID().uuidString)
    }
    
    // MARK: - cloudKitRecord PUT
    var cloudKitRecord: CKRecord {
        
        let record = CKRecord(recordType: Keys.recordUserType, recordID: recordID)
        record.setValue(projectedIncome, forKey: Keys.projectedIncomeKey)
        record.setValue(hasResetMonthlyBudget, forKey: Keys.hasResetMonthlyBudget)
        return record
    }
    
    // MARK: - Failiable initializer with cloudKitRecord
    init?(cloudKitRecord: CKRecord) {
        
        guard let projectedIncome = cloudKitRecord[Keys.projectedIncomeKey] as? Double,
        let hasResetMonthlyBudget = cloudKitRecord[Keys.hasResetMonthlyBudget] as? Bool? else { return nil }
        self.projectedIncome = projectedIncome
        self.hasResetMonthlyBudget = hasResetMonthlyBudget
        self.recordID = cloudKitRecord.recordID
    }
}
