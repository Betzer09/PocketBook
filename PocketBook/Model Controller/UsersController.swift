//
//  UsersController.swift
//  PocketBook
//
//  Created by Brian Weissberg on 11/16/17.
//  Copyright © 2017 SPARQ. All rights reserved.


import Foundation
import CloudKit

class UsersController {
    
    static let shared = UsersController()
    
    // MARK: - Properties
    let cloudKitManager: CloudKitManager
    let privateDatabase = CKContainer.default().privateCloudDatabase
    
    // Source of truth
    var users: [Users] = [] {
        
        didSet {
            NotificationCenter.default.post(name: Notifications.userWasUpdatedNotification, object: nil)
        }
    }
    
    init() {
        self.cloudKitManager = CloudKitManager()
        fetchAccountsFromCloudKit()
    }
    
    // MARK: - Save Data
    
    func createUser(projectedIncome: Double, completion: ((Users) -> Void)? ) {
        
        // Create a user
        let user = Users(projectedIncome: projectedIncome)
        
        users.append(user)
        
        cloudKitManager.saveRecord(user.cloudKitRecord) { (_, error) in
            
            if let error = error {
                print("Error saving account to cloudKit: \(error.localizedDescription) in file: \(#file)")
                return
            }
            completion?(user)
            return
        }
    }
    
    // MARK: - Update
    func updateUserWith(projectedIncome: Double, user: Users, completion: @escaping (Users?) -> Void) {
        
        user.projectedIncome = projectedIncome
        
        cloudKitManager.modifyRecords([user.cloudKitRecord], perRecordCompletion: nil, completion: { (records, error) in
            
            // Check for an error
            if let error = error {
                print("Error saving new records: \(error.localizedDescription) in file: \(#file)")
                completion(nil)
                return
            }
            
            // Update the first Account that comes back
            guard let record = records?.first else {return}
            let updatedUser = Users(cloudKitRecord: record)
            completion(updatedUser)
        })
    }
    
    // MARK: - Delete
    func delete(user: Users) {
        
        cloudKitManager.deleteRecordWithID(user.recordID) { (recordID, error) in
            if let error = error {
                print("Error deleting Account: \(error.localizedDescription) in file: \(#file)")
                return
            } else {
                print("Successfully deleted Account")
            }
        }
    }
    
    // MARK: - Fetch the data from cloudKit
    func fetchAccountsFromCloudKit() {
        
        // Get all of the accounts
        let predicate = NSPredicate(value: true)
        
        // Create a query
        let query = CKQuery(recordType: Keys.recordUsersType, predicate: predicate)
        
        // Fetch the data form cloudkit
        privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
            
            // Check for an errror
            if let error = error {
                print("Error fetching the Accounts Data: \(error.localizedDescription) in file: \(#file)")
            }
            
            guard let records = records else {return}
            
            // Send the accounts through the cloudKit Initilizer
            let users = records.flatMap( {Users(cloudKitRecord: $0)})
            
            self.users = users
        }
    }
}




