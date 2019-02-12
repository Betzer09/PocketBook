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
    
    // Source of truth
    var accounts: [Account] = [] {
        
        didSet {
            NotificationCenter.default.post(name: Notifications.accountWasUpdatedNotification, object: nil)
        }
    }
    
    init() {
        self.cloudKitManager = CloudKitManager()
        fetchAccountsFromCloudKit()
    }
    
    // MARK: - Methods
    
    /// This function takes an account and returns the index value of that account out of the AccountController.shared.accounts array
    func getIntIndex(forAccount account: Account) -> Int {
        
        var indexInteger: Int = 0
        let accounts = AccountController.shared.accounts
        let accountIndex = accounts.index{$0 === account}
        guard let index = accountIndex else { return 0 }
        let indexString = String(index)
        let indexInt = Int(indexString)
        guard let intIndex = indexInt else { return 0 }
        indexInteger = intIndex
        return indexInteger
    }
    
    /// This function takes an array of accounts and adds up the total balance for all accounts and returns that value as a double.
    func addUpAccountAmounts(fromAccountArray array: [Account]) -> Double {
        
        var totalAmount: Double = 0.0
        for account in array {
            totalAmount += account.total
        }
        return totalAmount
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
    func updateAccountWith(name: String, type: String, total: Double, account: Account, completion: @escaping (Account?) -> Void = {_ in}) {
        
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
            guard let record = records?.first else {completion(nil); return}
            let updatedAccount = Account(cloudKitRecord: record)
            completion(updatedAccount)
        })
    }
    
    // MARK: - Delete
    func delete(account: Account) {
        
        cloudKitManager.deleteRecordWithID(account.recordID) { (recordID, error) in
            if let error = error {
                print("Error deleting Account: \(error.localizedDescription) in file: \(#file)")
                return
            } else {
                print("Successfully deleted Account")
            }
        }
    }
    
    // MARK: - Fetch the data from cloudKit
    func fetchAccountsFromCloudKit(completion: @escaping(_ complete: Bool) -> Void = {_ in}) {
        
        // Get all of the accounts
        let predicate = NSPredicate(value: true)
        
        // Create a query
        let query = CKQuery(recordType: Keys.recordAccountType, predicate: predicate)
        
        // Fetch the data form cloudkit
        privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
            
            // Check for an errror
            if let error = error {
                print("Error fetching the Accounts Data: \(error.localizedDescription) in file: \(#file)")
                completion(false)
            }
            
            guard let records = records else {completion(false) ;return}
            
            // Send the accounts through the cloudKit Initilizer
            let accounts = records.compactMap( {Account(cloudKitRecord: $0)})
            
            self.accounts = accounts
            completion(true)
        }
    }
    
    /// Adds the amount to the account and then saves it to CloudKit
    func addAmountToAccountWith(amount: Double, account: Account, completion: @escaping(_ complete: Bool) -> Void) {
        account.total += amount
        updateAccountWith(name: account.name, type: account.accountType, total: account.total, account: account) { (updatedAccount) in
            guard updatedAccount != nil else {completion(false) ;return}
            completion(true)
        }
    }
    
    func substractAmountFromAccountWith(amount: Double, account: Account, completion: @escaping(_ complete: Bool) -> Void = {_ in}) {
        account.total -= amount
        updateAccountWith(name: account.name, type: account.accountType, total: account.total, account: account) { (updatedAccount) in
            guard updatedAccount != nil else {completion(false) ;return}
            completion(true)
        }
    }
}











