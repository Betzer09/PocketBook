//
//  Account.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/7/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation
import CloudKit

enum AccountType: String {
    case Checking = "Checking"
    case Saving = "Saving"
    case CreditCard = "CreditCard"
    
}

class Account {
    
    // MARK: - Keys
    static let recordType = "Account"
    
    static let accountTypeKey = "accountType"
    static let nameKey = "name"
    static let totalKey = "total"
    
    // MARK: - Properties
    var accountType: String
    var name: String
    var total: Double
    var recordID: CKRecordID
    
    init(name: String, total: Double, accountType: AccountType.RawValue) {
        self.accountType = accountType
        self.name = name
        self.total = total
        self.recordID = CKRecordID(recordName: UUID().uuidString)
    }
    
    // MARK: - cloudKitRecord PUT
    var cloudKitRecord: CKRecord {
        
        let record = CKRecord(recordType: Account.recordType, recordID: recordID)
        
        record.setValue(name, forKey: Account.nameKey)
        record.setValue(accountType, forKey: Account.accountTypeKey)
        record.setValue(total, forKey: Account.totalKey)
                
        return record
    }
    
    // MARK: - Failiable initializer with cloudKitRecord
    init?(cloudKitRecord: CKRecord) {
        guard let name = cloudKitRecord[Account.nameKey] as? String,
            let accountType = cloudKitRecord[Account.accountTypeKey] as? String,
            let total = cloudKitRecord[Account.totalKey] as? Double else {return nil}
        
        self.name = name
        self.accountType = accountType
        self.total = total
        self.recordID = cloudKitRecord.recordID
    }
}
