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
    
    func updateBudgetWith(name: String, spentTotal: Double, totalAlloted: Double? = nil, allottedAmount: Double, budgetItem: BudgetItem, completion: @escaping(BudgetItem?) -> Void) {
        
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
    
    // MARK: - Reset BudgetItems SpentTotal
    func resetSpentTotal() {
        let budgetItems = BudgetItemController.shared.budgetItems
        for budgetItem in budgetItems {
            budgetItem.spentTotal = 0
            updateBudgetWith(name: budgetItem.name, spentTotal: budgetItem.spentTotal, allottedAmount: budgetItem.allottedAmount, budgetItem: budgetItem, completion: { (_) in
                //TODO: FIX ME
            })
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
    
    /// Configures the monthly budget for the budgetItem
    public func configureMonthlyBudgetExpensesForBudgetItem(transaction: Transaction, transactionType: TransactionType, account: Account, budgetItem: BudgetItem?, difference: Double = 0,
                                                            completion: @escaping (_ success: Bool) -> Void = {_ in} ) {
        
        // We want to check the current date with transaction date for both planned Expenses and transactions
        let transactionMonth = dateComponentMonth(date: transaction.date)
        let currentMonth = dateComponentMonth(date: Date())
        let plannedExpenses = PlannedExpenseController.shared.plannedExpenses
        
        if transactionType == .removePlannedExpense {
            account.total += transaction.amount
            AccountController.shared.updateAccountWith(name: account.name, type: account.accountType, total: account.total, account: account, completion: { (account) in
                guard let _ = account else {completion(false); return}
                completion(true)
            })
            return
        }
        
        guard let budgetItem = budgetItem else {
            guard let category = transaction.category else {return}
            if checkForPlannedExpenseWith(name: category) {
                guard let plannedexpense = plannedExpenses.first(where: { $0.name == category }) else {return}
                handlePlannedExpenseTransaction(transaction: transaction, account: account, plannedexpense: plannedexpense)
            }
            return
        }
        
        if transactionType == .expense {
            account.total -= difference
            
            if transactionMonth == currentMonth {
                budgetItem.spentTotal += difference
            }
            
            
            
            BudgetItemController.shared.updateBudgetWith(name: budgetItem.name, spentTotal: budgetItem.spentTotal, allottedAmount: budgetItem.allottedAmount, budgetItem: budgetItem, completion: { (updatedBudgetItem) in
                guard let _ = updatedBudgetItem else {
                    completion(false)
                    return
                }
                AccountController.shared.updateAccountWith(name: account.name, type: account.accountType, total: account.total, account: account) { (account) in
                    guard let _ = account else {completion(false); return}
                    completion(true)
                }
            })
            
        }
        
        if transactionType == .income {
            account.total += transaction.amount
            if transactionMonth == currentMonth {
                guard let totalAlloted = budgetItem.totalAllotted else {return}
                budgetItem.totalAllotted = totalAlloted + transaction.amount
            }
            
            
            BudgetItemController.shared.updateBudgetWith(name: budgetItem.name, spentTotal: budgetItem.spentTotal, allottedAmount: budgetItem.allottedAmount, budgetItem: budgetItem, completion: { (updatedBudgetItem) in
                
                guard let _ = updatedBudgetItem else {completion(false) ;return}
                AccountController.shared.updateAccountWith(name: account.name, type: account.accountType, total: account.total, account: account) { (account) in
                    guard let _ = account else {return}
                    completion(true)
                }
            })
            
        }
        
        if transactionType == .removeIncome {
            if transactionMonth == currentMonth {
                guard let totalAllotted = budgetItem.totalAllotted else {return}
                budgetItem.totalAllotted = totalAllotted - transaction.amount
                BudgetItemController.shared.updateBudgetWith(name: budgetItem.name, spentTotal: budgetItem.spentTotal, allottedAmount: budgetItem.allottedAmount, budgetItem: budgetItem, completion: { (_) in })
            }
            account.total -= transaction.amount
            AccountController.shared.updateAccountWith(name: account.name, type: account.accountType, total: account.total, account: account, completion: { (_) in
                completion(true)
            })
        }
        
        if transactionType == .removeExpense {
            if transactionMonth == currentMonth {
                budgetItem.spentTotal -= transaction.amount
                BudgetItemController.shared.updateBudgetWith(name: budgetItem.name, spentTotal: budgetItem.spentTotal, allottedAmount: budgetItem.allottedAmount, budgetItem: budgetItem, completion: { (_) in })
            }
            account.total += transaction.amount
            AccountController.shared.updateAccountWith(name: account.name, type: account.accountType, total: account.total, account: account, completion: { (_) in
                completion(true)
            })
        }
        
    }
    
    func checkForPlannedExpenseWith(name: String) -> Bool {
        let plannedExpenses = PlannedExpenseController.shared.plannedExpenses
        let indexOfPlannedExpense = plannedExpenses.firstIndex(where: { $0.name == name })
        if indexOfPlannedExpense == nil {
            return false
        }
        return true
    }
    
    func handlePlannedExpenseTransaction(transaction: Transaction, account: Account, plannedexpense: PlannedExpense) {
        // Subtract transaction amount from total
        let updatedAccount = account.total - transaction.amount
        
        // Add amount to savings goal
        
        // Create Transaction
        

    }
}

