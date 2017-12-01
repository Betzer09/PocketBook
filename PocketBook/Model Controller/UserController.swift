//
//  UsersController.swift
//  PocketBook
//
//  Created by Brian Weissberg on 11/16/17.
//  Copyright © 2017 SPARQ. All rights reserved.


import Foundation
import CloudKit

class UserController {
    
    static let shared = UserController()
    
    // MARK: - Properties
    let cloudKitManager: CloudKitManager
    let privateDatabase = CKContainer.default().privateCloudDatabase
    
    var user: User? {
        didSet {
            NotificationCenter.default.post(name: Notifications.userWasUpdatedNotification, object: nil)
        }
    }
    
    init() {
        self.cloudKitManager = CloudKitManager()
        fetchUserFromCloudKit()
    }
    
    // MARK: - Save Data
    
    func createUser(withProjectedIncome income: Double, completion: ((User?) -> Void)? ) {
        
        // Create a user
        let user = User(projectedIncome: income)
        
        cloudKitManager.saveRecord(user.cloudKitRecord) { (_, error) in
            
            if let error = error {
                print("Error saving user to cloudKit: \(error.localizedDescription) in file: \(#file)")
                return
            }
            
            NSLog("User Successfully Created")
            self.user = user
            completion?(user)
        }
    }
    
    // MARK: - Update
    func updateUserWith(projectedIncome: Double, user: User, completion: @escaping (User?) -> Void) {
        
        user.projectedIncome = projectedIncome
        
        cloudKitManager.modifyRecords([user.cloudKitRecord], perRecordCompletion: nil, completion: { (records, error) in
            
            // Check for an error
            if let error = error {
                print("Error saving new records: \(error.localizedDescription) in file: \(#file)")
                completion(nil)
                return
            }
            
            // Update the first User that comes back
            guard let record = records?.first else {return}
            let updatedUser = User(cloudKitRecord: record)
            completion(updatedUser)
        })
    }
    
    // MARK: - Delete
    func delete(user: User) {
        
        cloudKitManager.deleteRecordWithID(user.recordID) { (recordID, error) in
            if let error = error {
                print("Error deleting User: \(error.localizedDescription) in file: \(#file)")
                return
            } else {
                print("Successfully deleted User")
            }
        }
    }
    
    // MARK: - Fetch the data from cloudKit
    func fetchUserFromCloudKit() {
        
        // Get all of the users
        let predicate = NSPredicate(value: true)
        
        // Create a query
        let query = CKQuery(recordType: Keys.recordUserType, predicate: predicate)
        
        // Fetch the data form cloudkit
        privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
            
            // Check for an error
            if let error = error {
                print("Error fetching the Users Data: \(error.localizedDescription) in file: \(#file)")
            }
            
            guard let records = records else {NSLog("There were no User Records found \(#file)");  return}
            
            // There should only ever be one user
            let user = records.flatMap({User(cloudKitRecord: $0)})
            
            // Assign the value with the user that comes back
            self.user = user.first
            
        }
    }
}




