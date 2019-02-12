//
//  BudgetItemController.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/7/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

class BudgetItemController {
    
    static let shared = BudgetItemController()
    
    // MARK: - Properties
    let cloudKitManager: CloudKitManager
    let privateDatabase = CKContainer.default().privateCloudDatabase
    
    // Source of truth
    var budgetItems: [BudgetItem] = [] {
        didSet {
            NotificationCenter.default.post(name: Notifications.budgetItemWasUpdatedNotifaction, object: nil)
        }
    }
    
    init() {
        self.cloudKitManager = CloudKitManager()
    }
    
    // MARK: - Creation
    func createBudgetItemWith(name: String, spentTotal: Double, allottedAmount: Double, completion: ((BudgetItem) -> Void)? ) {
        
        let budgetItem = BudgetItem(spentTotal: spentTotal, name: name, allottedAmount: allottedAmount)
        budgetItems.append(budgetItem)
        
        self.budgetItems = budgetItems.sorted(by: {$0.name < $1.name})
        
        cloudKitManager.saveRecord(budgetItem.cloudKitRecord) { (record, error) in
            if let error = error {
                print("Error saving Budget Item: \(error.localizedDescription) in file \(#file)")
                return
            }
            completion?(budgetItem)
            return
        }
    }
    
    // MARK: - Modificiation / Update
    
    func updateBudgetWith(name: String, spentTotal: Double, totalAlloted: Double? = nil, allottedAmount: Double, budgetItem: BudgetItem, completion: @escaping(BudgetItem?) -> Void = {_ in}) {
        
        budgetItem.name = name
        budgetItem.spentTotal = spentTotal
        budgetItem.allottedAmount = allottedAmount
        if let totalAlloted = totalAlloted {
            budgetItem.totalAllotted = totalAlloted
        }
        
        cloudKitManager.modifyRecords([budgetItem.cloudKitRecord], perRecordCompletion: nil) { (records, error) in
            if let error = error {
                NSLog("Error updating Budget Item: \(error.localizedDescription) in file: \(#file)")
                completion(nil)
                return
            }
            
            guard let record = records?.first else {completion(nil) ;return}
            let updatedBudgetItem = BudgetItem(cloudKitRecord: record)
            completion(updatedBudgetItem)
        }
    }
    
    // MARK: - Deletion
    func delete(budgetItem: BudgetItem) {
        
        cloudKitManager.deleteRecordWithID(budgetItem.recordID) { (_, error) in
            if let error = error {
                NSLog("Error deleting Budget Item: \(error.localizedDescription) in file: \(#file)")
                return
            } else {
                print("Succesfully deleted Budget Item")
            }
        }
    }
    
    // MARK: - Reset BudgetItems SpentTotal
    func resetSpentTotal() {
        let budgetItems = BudgetItemController.shared.budgetItems
        for budgetItem in budgetItems {
            budgetItem.spentTotal = 0
            updateBudgetWith(name: budgetItem.name, spentTotal: budgetItem.spentTotal, allottedAmount: budgetItem.allottedAmount, budgetItem: budgetItem)
        }
    }
    
    
    // MARK: - Fetching Data from cloudKit
    func fetchBugetItemFromCloudKit() {
        
        // Get all of the accounts
        let predicate = NSPredicate(value: true)
        
        // Create a query
        let query = CKQuery(recordType: Keys.recordBudgetItemType, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: Keys.budgetItemNameKey, ascending: true)]
        
        // Fetch the data form cloudkit
        privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
            
            // Check for an errror
            if let error = error {
                print("Error fetching the Accounts Data: \(error.localizedDescription) in file: \(#file)")
            }
            
            guard let records = records else {return}
            // Send the accounts through the cloudKit Initilizer
            let bugetItems = records.compactMap( {BudgetItem(cloudKitRecord: $0)})
            self.budgetItems = bugetItems
        }
    }
    
    // MARK: - Methods
    func addSpentTotalAmountToBudgetItem(amount: Double, budgetItem: BudgetItem) {
        budgetItem.spentTotal += amount
        updateBudgetWith(name: budgetItem.name, spentTotal: budgetItem.spentTotal, allottedAmount: budgetItem.allottedAmount, budgetItem: budgetItem)
    }
    
    /// Subtracts whatever the amount is from the spent total
    func substractSpentTotalAmountFromBudgetItem(amount: Double, budgetItem: BudgetItem) {
        budgetItem.spentTotal -= amount
        updateBudgetWith(name: budgetItem.name, spentTotal: budgetItem.spentTotal, allottedAmount: budgetItem.allottedAmount, budgetItem: budgetItem)
    }
    
    
    func addTotalAllotedAmountToBudgetItem(amount: Double, budgetItem: BudgetItem) {
        guard let totalAlloted = budgetItem.totalAllotted else {return}
        let newTotal = totalAlloted + amount
        budgetItem.totalAllotted = newTotal
        updateBudgetWith(name: budgetItem.name, spentTotal: budgetItem.spentTotal, allottedAmount: budgetItem.allottedAmount, budgetItem: budgetItem)
    }
    
    /// Subtracts whatever the amount is from the totalAlloted
    func substractTotalAllotedAmountFromBudgetItem(amount: Double, budgetItem: BudgetItem) {
        guard let totalAlloted = budgetItem.totalAllotted else {return}
        let newTotal = totalAlloted - amount
        budgetItem.totalAllotted = newTotal
        updateBudgetWith(name: budgetItem.name, spentTotal: budgetItem.spentTotal, allottedAmount: budgetItem.allottedAmount, budgetItem: budgetItem)
    }
}

