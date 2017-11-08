//
//  AccountModel.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/7/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation
import CloudKit

class AccountController {
    
    static let shared = AccountController()
    
    // MARK: - Properties
    let cloudKitManager: CloudKitManager
    let privateDatabase = CKContainer.default().privateCloudDatabase
    
    // MARK: - Notifications
    let accountsWhereUpdatedNotification = Notification.Name("accountWasUpdated")
    
    // Source of truth
    var accounts: [Account] = [] {
        
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: self.accountsWhereUpdatedNotification, object: nil)
            }
        }
    }
    
    
    init() {
        self.cloudKitManager = CloudKitManager()
    }
    
    // MARK: - Save Data
    
    func createAccount(name: String, type: String, total: Double, completion: ((Account) -> Void)? ) {
        
        // Create an account
        let account = Account(name: name, total: total, accountType: type)
        accounts.append(account)
        
        cloudKitManager.saveRecord(account.cloudKitRecord) { (_, error) in
            
            if let error = error {
                print("Error saving account to cloudKit: \(error.localizedDescription) in file: \(#file)")
                return
                
            }
            
            completion?(account)
            return
        }
    }
    
    // MARK: - Update
    func updateAccountWith(name: String, type: String, total: Double, account: Account, completion: @escaping (Account?) -> Void) {
        
        account.name = name
        account.accountType = type
        account.total = total
        
        cloudKitManager.modifyRecords([account.cloudKitRecord], perRecordCompletion: nil, completion: { (records, error) in
            
            // Check for an error
            if let error = error {
                print("Error saving new records: \(error.localizedDescription) in file: \(#file)")
                completion(nil)
                return
            }
            
            // Update the first Account that comes back
            guard let record = records?.first else {return}
            let updatedAccount = Account(cloudKitRecord: record)
            completion(updatedAccount)
            
        })
        
    }
    
    func delete(account: Account) {
        
        cloudKitManager.deleteRecordWithID(account.recordID) { (recordID, error) in
            if let error = error {
                print("Error deleting Account: \(error.localizedDescription) in file: \(#file)")
                return
            } else {
                print("Successfully deleted Account!")
            }
        }
        
    }
    
    
    // MARK: - Fetch the data from cloudKit
    func fetchAccountsFromCloudKit() {
        
        // Get all of the accounts
        let predicate = NSPredicate(value: true)
        
        // Create a query
        let query = CKQuery(recordType: Account.recordType, predicate: predicate)
        
        // Fetch the data form cloudkit
        privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
            
            // Check for an errror
            if let error = error {
                print("Error fetching the Accounts Data: \(error.localizedDescription) in file: \(#file)")
            }
            
            guard let records = records else {return}
            
            // Send the accounts through the cloudKit Initilizer
            let accounts = records.flatMap( {Account(cloudKitRecord: $0)})
            
            self.accounts = accounts
        }
        
    }
    
}
