//
//  Account.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/7/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation
import CloudKit

class Account {
    
    // MARK: - Properties
    private var _name: String = ""
    
    var accountType: String
    var total: Double
    var recordID: CKRecord.ID
    var name: String
    
    init(name: String, total: Double, accountType: AccountType.RawValue) {
        self.accountType = accountType
        self.name = name
        self.total = total
        self.recordID = CKRecord.ID(recordName: UUID().uuidString)
    }
    
    // MARK: - cloudKitRecord PUT
    var cloudKitRecord: CKRecord {
        
        let record = CKRecord(recordType: Keys.recordAccountType, recordID: recordID)
        
        record.setValue(name, forKey: Keys.accountNameKey)
        record.setValue(accountType, forKey: Keys.accountTypeKey)
        record.setValue(total, forKey: Keys.totalKey)
        
        return record
    }
    
    // MARK: - Failiable initializer with cloudKitRecord
    init?(cloudKitRecord: CKRecord) {
        guard let name = cloudKitRecord[Keys.accountNameKey] as? String,
            let accountType = cloudKitRecord[Keys.accountTypeKey] as? String,
            let total = cloudKitRecord[Keys.totalKey] as? Double else {return nil}
        
        self.name = name
        self.accountType = accountType
        self.total = total
        self.recordID = cloudKitRecord.recordID
    }
}
