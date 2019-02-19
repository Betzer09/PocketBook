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
    var plannedExpenses: [PlannedExpense] = [] {
        
        didSet {
            NotificationCenter.default.post(name: Notifications.plannedExpenseWasUpdatedNotification, object: nil)
        }
    }

    
    init() {
        self.cloudKitManager = CloudKitManager()
    }
    
    // MARK: - Methods
    /// This function adds up the total of all current planned expense savings goals
    func addUpTotalDepositedToSavings() -> Double {
        
        var totalDepositedToGoal: Double = 0.0
        for plannedExpense in PlannedExpenseController.shared.plannedExpenses {
            totalDepositedToGoal += plannedExpense.totalDeposited
        }
        return totalDepositedToGoal
    }
    
    
    
    /// This function calculates the total monthly contribtion needed for all planned expenses
    func calculateTotalMonthlyContribution() -> Double {
        
        var totalIdealContribution: Double = 0.0
        for plannedExpense in plannedExpenses {
            guard let amountDifference = amountDifference(goalAmount: plannedExpense.goalAmount, currentAmount: plannedExpense.totalDeposited),
                let calculatedMonthsToDueDate = calculatedMonthsToDueDate(dueDate: plannedExpense.dueDate, currentDate: Date()) else { return 0.0 }
            let monthlyContribution = (amountDifference / Double(calculatedMonthsToDueDate))
            totalIdealContribution += monthlyContribution
        }
        return totalIdealContribution
    }
    
    /// This function calculates the remaining amount needed to reach goal
    func amountDifference(goalAmount: Double, currentAmount: Double) -> Double? {
        let difference = goalAmount - currentAmount
        return difference
    }
    
    /// This function calculates the number of months between two dates
    func calculatedMonthsToDueDate(dueDate: Date, currentDate: Date) -> Int? {
        let dueDateComponents = calendar.dateComponents([.year, .month], from: dueDate)
        let currentDateComponents = calendar.dateComponents([.year, .month], from: currentDate)
        guard let dueDateYear = dueDateComponents.year,
            let dueDateMonth = dueDateComponents.month,
            let currentMonth = currentDateComponents.month,
            let currentYear = currentDateComponents.year else { return nil }
        let yearRemainder = dueDateYear - currentYear
        let monthRemainder = (dueDateMonth - currentMonth)
        let total = ((yearRemainder * 12) + monthRemainder) + 1
        return total
    }

    // MARK: - Create / Save
    func createPlannedExpenseWith(name: String, account: String, goalAmount: Double, dueDate: Date, totalDeposited: Double, completion: ((PlannedExpense)-> Void)? ) {
        let plannedExpense = PlannedExpense(name: name, account: account, dueDate: dueDate, goalAmount: goalAmount, totalDeposited: totalDeposited)
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
    
    
    // MARK: - Update
    
    func createPlannedExpenseTransaction(transaction: Transaction, account: Account, categoryName: String) {
        // If the inital amount isn't greater than zero there is no point in creating a transaction.
        guard transaction.amount != 0 else {return}
        TransactionController.shared.createTransactionWith(date: transaction.date, monthYearDate: transaction.monthYearDate, category: transaction.category, payee: transaction.payee, transactionType: TransactionType.expense , amount: transaction.amount, account: account.name)
        TransactionController.shared.handlePlannedExpenseTransactionWtih(plannedexpense: categoryName, amount: transaction.amount, account: account)
    }
    
    func updatePlannedExpenseWith(name: String, account: String, goalAmount: Double, totalDeposited: Double, dueDate: Date, plannedExpense: PlannedExpense, completion: @escaping (PlannedExpense?) -> Void = {_ in}) {
        
        plannedExpense.name = name
        plannedExpense.account = account
        plannedExpense.goalAmount = goalAmount
        plannedExpense.dueDate = dueDate
        if totalDeposited < 0 {
            plannedExpense.totalDeposited = 0
        } else {
            plannedExpense.totalDeposited = totalDeposited            
        }
        
        cloudKitManager.modifyRecords([plannedExpense.cloudKitRecord], perRecordCompletion: nil) { (records, error) in
            guard let record = records?.first else {return}
            let updatedPlannedExpense = PlannedExpense(cloudKitRecord: record)
            completion(updatedPlannedExpense)
            
        }
        
    }
    
    func addAmountToTotalDeposited(amount: Double, plannedexpense: PlannedExpense) {
        let total = plannedexpense.totalDeposited + amount
        
        updatePlannedExpenseWith(name: plannedexpense.name, account: plannedexpense.account, goalAmount: plannedexpense.goalAmount, totalDeposited: total, dueDate: plannedexpense.dueDate, plannedExpense: plannedexpense)
        
    }
    
    func subtractAmountoTotalDeposited(amount: Double, plannedexpense: PlannedExpense) {
        let total = plannedexpense.totalDeposited - amount
        
        updatePlannedExpenseWith(name: plannedexpense.name, account: plannedexpense.account, goalAmount: plannedexpense.goalAmount, totalDeposited: total, dueDate: plannedexpense.dueDate, plannedExpense: plannedexpense)
    }
    
    // MARK: - Delete plannedExpense
    // Removes Planned Expense when it has been completed
    func remove(plannedexpense: PlannedExpense) {
        cloudKitManager.deleteRecordWithID(plannedexpense.recordID) { (_, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            
            guard let index = self.plannedExpenses.firstIndex(of: plannedexpense) else {return}
            self.plannedExpenses.remove(at: index)
        }
    }
    func delete(plannedExpense: PlannedExpense) {
        cloudKitManager.deleteRecordWithID(plannedExpense.recordID) { (_, error) in
            if let error = error {
                print("Error deleting Planned Expense \(error.localizedDescription) in file: \(#file)")
                return
            } else {
                guard let indexForAccount = AccountController.shared.accounts.index(where: { $0.name == plannedExpense.account }) else {return}
                let account = AccountController.shared.accounts[indexForAccount]
                
                self.removePlannedExpenseWith(plannedExpense: plannedExpense, account: account)
            }
        }
    }
    
    func removePlannedExpenseWith(plannedExpense: PlannedExpense, account: Account) {
        
        let totalSaved = plannedExpense.totalDeposited
        account.total += totalSaved
        AccountController.shared.updateAccountWith(name: account.name, type: account.accountType, total: account.total, account: account) { (_) in}

    }
    
    // MARK: - Fetch from cloudKit
    func fetchPlannedExpensesFromCloudKit(completion: @escaping(_ complete: Bool) -> Void = {_ in}) {
        
        // Get all of the accounts
        let predicate = NSPredicate(value: true)
        
        // Create a query
        let query = CKQuery(recordType: Keys.recordPlannedExpenseType, predicate: predicate)
        
        // Fetch the data form cloudkit
        privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
            
            // Check for an errror
            if let error = error {
                print("Error fetching the Accounts Data: \(error.localizedDescription) in file: \(#file)")
                completion(false)
            }
            
            guard let records = records else {completion(false) ;return}
            
            // Send the accounts through the cloudKit Initilizer
            let plannedExpense = records.compactMap( { PlannedExpense(cloudKitRecord: $0)})
            
            self.plannedExpenses = plannedExpense
            completion(true)
        }
    }
}
