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
    
    // MARK: - Notification
    let budgetItemWasUpdatedNotifaction = Notification.Name("bugetItemWasUpdated")
    
    // Source of truth
    var budgetItems: [BudgetItem] = [] {
        didSet {
            NotificationCenter.default.post(name: budgetItemWasUpdatedNotifaction, object: nil)
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
    func updateBudgetWith(name: String, spentTotal: Double, allottedAmount: Double, budgetItem: BudgetItem, completion: @escaping(BudgetItem?) -> Void) {
        
        budgetItem.name = name
        budgetItem.spentTotal = spentTotal
        budgetItem.allottedAmount = allottedAmount
        
        cloudKitManager.modifyRecords([budgetItem.cloudKitRecord], perRecordCompletion: nil) { (records, error) in
            if let error = error {
                NSLog("Error updating Budget Item: \(error.localizedDescription) in file: \(#file)")
                completion(nil)
                return
            }
            
            guard let record = records?.first else {return}
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
    
    
    // MARK: - Fetching Data from cloudKit
    func fetchBugetItemFromCloudKit() {
        
        
        // Get all of the accounts
        let predicate = NSPredicate(value: true)
        
        // Create a query
        let query = CKQuery(recordType: BudgetItem.recordType, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: BudgetItem.nameKey, ascending: true)]
        
        // Fetch the data form cloudkit
        privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
            
            // Check for an errror
            if let error = error {
                print("Error fetching the Accounts Data: \(error.localizedDescription) in file: \(#file)")
            }
            
            guard let records = records else {return}
            // Send the accounts through the cloudKit Initilizer
            let bugetItems = records.flatMap( {BudgetItem(cloudKitRecord: $0)})
            self.budgetItems = bugetItems
        }
    }

    
    // MARK: - Methods
    
    ///Returns the transactionType
    public func checkTransactionType(transactionSegmentedControl: UISegmentedControl) -> TransactionType {
        
        var transactionType = TransactionType.all
        
        if transactionSegmentedControl.titleForSegment(at: transactionSegmentedControl.selectedSegmentIndex) == "Income" {
            transactionType = TransactionType.income
        } else {
            transactionType = TransactionType.income
        }
        
        
        return transactionType
    }
    
    /// Configures the monthly budget for the budgetItem
    public func configureMonthlyBudgetExpensesForBudgetItem(transaction: Transaction, transactionType: TransactionType, account: Account, budgetItem: BudgetItem) {
        
        if transactionType == .expense {
            
            account.total = account.total - transaction.amount
            
            // Make sure the right category is being manipuleted
            if transaction.category == budgetItem.name {
                
                guard let totalAllotted = budgetItem.totalAllotted else {return}
                budgetItem.totalAllotted = totalAllotted - transaction.amount
                budgetItem.spentTotal = budgetItem.spentTotal + transaction.amount
                
            }
            
        } else {
            // add
            
            account.total = account.total + transaction.amount
            
            if transaction.category == budgetItem.name {
                guard let totalAllotted = budgetItem.totalAllotted else {return}
                budgetItem.totalAllotted = totalAllotted + transaction.amount
            }
        }
        
    }
    
}




















