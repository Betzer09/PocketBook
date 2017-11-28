//
//  Users.swift
//  PocketBook
//
//  Created by Brian Weissberg on 11/16/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation
import CloudKit

class User {
    
    // MARK: - Properties
    var projectedIncome: Double
    let recordID: CKRecordID
    
    init(projectedIncome: Double) {
        self.projectedIncome = projectedIncome
        self.recordID = CKRecordID(recordName: UUID().uuidString)
    }
    
    // MARK: - cloudKitRecord PUT
    var cloudKitRecord: CKRecord {
        
        let record = CKRecord(recordType: Keys.recordUserType, recordID: recordID)
        record.setValue(projectedIncome, forKey: Keys.projectedIncomeKey)
        return record
    }
    
    // MARK: - Failiable initializer with cloudKitRecord
    init?(cloudKitRecord: CKRecord) {
        
        guard let projectedIncome = cloudKitRecord[Keys.projectedIncomeKey] as? Double else { return nil }
        self.projectedIncome = projectedIncome
        self.recordID = cloudKitRecord.recordID
    }
}
