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

struct Account {
    
    // MARK: - Keys
    static let recordType = "Account"
    
    static let accountTypeKey = "accountType"
    static let nameKey = "name"
    static let totalKey = "total"
    
    // MARK: - Properties
    let accountType: String
    let name: String
    let total: Double
    
    init(name: String, total: Double, accountType: AccountType.RawValue) {
        self.accountType = accountType
        self.name = name
        self.total = total
    }
    
    // MARK: - cloudKitRecord PUT
    var cloudKitRecord: CKRecord {
        let record = CKRecord(recordType: Account.recordType)
        
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
        
    }
    
    
}
