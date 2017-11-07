//
//  PlannedExpenseController.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/7/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation
import CloudKit

class PlannedExpenseController {
    
    static let shared = PlannedExpenseController()
    
    // MARK: - Properties
    let cloudKitManager: CloudKitManager
    let privateDatabase = CKContainer.default().privateCloudDatabase
    
    // Souces of truth
    var plannedExpenses: [PlannedExpense] = []
    
    init() {
        self.cloudKitManager = CloudKitManager()
    }
    
    // MARK: - Create / Save
    func createPlannedExpenseWith(name: String, account: String, initialAmount: Double, goalAmount: Double, dueDate: Date, completion: ((PlannedExpense)-> Void)? ) {
        let plannedExpense = PlannedExpense(name: name, account: account, dueDate: dueDate, initialAmount: initialAmount, goalAmount: goalAmount)
        plannedExpenses.append(plannedExpense)
        
        cloudKitManager.saveRecord(plannedExpense.cloudKitRecord) { (record, error) in
            if let error = error {
                print("There was an error creating a Planned Expense: \(error.localizedDescription) in file \(#file)")
                return
            }

            completion?(plannedExpense)
            return
            
        }
        
    }
    
    
    // MARK: - Update an existing plannedExpense
    func updatePlannedExpenseWith(name: String, account: String, initialAmount: Double, goalAmount: Double, totalSaved: Double, dueDate: Date, plannedExpense: PlannedExpense, completion: @escaping (PlannedExpense?) -> Void) {
        
        plannedExpense.name = name
        plannedExpense.account = account
        plannedExpense.initialAmount = initialAmount
        plannedExpense.goalAmount = goalAmount
        plannedExpense.dueDate = dueDate
        
        cloudKitManager.modifyRecords([plannedExpense.cloudKitRecord], perRecordCompletion: nil) { (records, error) in
            
            // Get the first record
            guard let record = records?.first else {return}
            let updatedPlannedExpense = PlannedExpense(cloudKitRecord: record)
            completion(updatedPlannedExpense)
            
        }
        
    }
    
    // MARK: - Delete plannedExpense
    func delete(plannedExpense: PlannedExpense) {
        cloudKitManager.deleteRecordWithID(plannedExpense.recordID) { (_, error) in
            if let error = error {
                print("Error deleting Planned Expense \(error.localizedDescription) in file: \(#file)")
                return
            } else {
                print("Succesfully deleted Planned Expense")
            }
        }
    }
    
    // MARK: - Fetch from cloudKit
    func fetchTransActionsFromCloudKit() {
        
        
        // Get all of the accounts
        let predicate = NSPredicate(value: true)
        
        // Create a query
        let query = CKQuery(recordType: PlannedExpense.recordType, predicate: predicate)
        
        // Fetch the data form cloudkit
        privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
            
            // Check for an errror
            if let error = error {
                print("Error fetching the Accounts Data: \(error.localizedDescription) in file: \(#file)")
            }
            
            guard let records = records else {return}
            
            // Send the accounts through the cloudKit Initilizer
            let plannedExpense = records.flatMap( {PlannedExpense(cloudKitRecord: $0)})
            
            self.plannedExpenses = plannedExpense
        }
    }
    
}
