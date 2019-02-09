//
//  TransactionContoller.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/7/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation
import CloudKit

class TransactionController {
    
    static let shared = TransactionController()
    
    // MARK: - Properties
    let cloudKitManager: CloudKitManager
    let privateDatabase = CKContainer.default().privateCloudDatabase
    
    // Source of truth
    var transactions: [Transaction] = [] {
        didSet {
            NotificationCenter.default.post(name: Notifications.transactionWasUpdatedNotification, object: nil)
        }
    }
    
    init() {
        self.cloudKitManager = CloudKitManager()
    }
    
    // MARK: - Save Data
    func createTransactionWith(date: Date, monthYearDate: Date, category: String?, payee: String, transactionType: String, amount: Double, account: String, completion: ((Transaction) -> Void)? = {_ in}) {
        
        let transaction = Transaction(date: date, monthYearDate: returnFormattedDate(date: monthYearDate), category: category, payee: payee, transactionType: transactionType, amount: amount, account: account)
        transactions.append(transaction)
        
        cloudKitManager.saveRecord(transaction.cloudKitRecord) { (record, error) in
            
            if let error = error {
                print("Error saving Transaction to cloudKit: \(error.localizedDescription) in file: \(#file)")
                return
            }
            
            completion?(transaction)
            return
        }
    }
    
    // MARK: - Update Data
    
    func updateTransactionWith(transaction: Transaction, date: Date, monthYearDate: Date, category: String?, payee: String, transactionType: String, amount: Double, account: String, completion: @escaping (Transaction?) -> Void) {
        
        transaction.monthYearDate = monthYearDate
        transaction.date = date
        transaction.category = category
        transaction.payee = payee
        transaction.transactionType = transactionType
        transaction.amount = amount
        transaction.account = account
        
        cloudKitManager.modifyRecords([transaction.cloudKitRecord], perRecordCompletion: nil) { (records, error) in
            
            if let error = error {
                print("Error saving new Transaction: \(error.localizedDescription) in file: \(#file)")
                completion(nil)
                return
            }
            
            // Update the first Accout
            guard let record = records?.first else {return}
            let updatedTransaction = Transaction(cloudKitRecord: record)
            completion(updatedTransaction)
        }
        
    }
    
    // MARK: - Delete
    func delete(transaction: Transaction, completion: @escaping(_ success: Bool) -> Void = {_ in}) {
        
        cloudKitManager.deleteRecordWithID(transaction.recordID) { (_, error) in
            
            if let error = error {
                print("Error deleting Transaction: \(error.localizedDescription) in file: \(#file)")
                completion(false)
                return
            }
            
            // Remove transaction from local storage
            guard let transactionToRemove = self.transactions.firstIndex(of: transaction) else {return}
            self.transactions.remove(at: transactionToRemove)
            
            guard let account = AccountController.shared.accounts.first(where: { $0.name == transaction.account })
                else { completion(false) ;return }
            
            let budgetItems = BudgetItemController.shared.budgetItems
            
            self.handleIncomeAndExpenseTransactionsWith(budgetItems: budgetItems, transaction: transaction, account: account)
            self.handlePaydayTransaction(transaction: transaction, account: account)
            
            completion(true)
            }
    }
    
    // MARK: - Fetch Data from CloudKit
    func fetchTransActionsFromCloudKit() {
        
        // Get all of the accounts
        let predicate = NSPredicate(value: true)
        
        // Create a query
        let query = CKQuery(recordType: Keys.recordTransactionType, predicate: predicate)
        
        // Fetch the data form cloudkit
        privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
            
            // Check for an errror
            if let error = error {
                print("Error fetching the Accounts Data: \(error.localizedDescription) in file: \(#file)")
            }
            
            guard let records = records else {return}
            
            // Send the accounts through the cloudKit Initilizer
            let transaction = records.compactMap( {Transaction(cloudKitRecord: $0)})
            
            self.transactions = transaction
        }
    }
    
    // MARK: - Methods
    
    func handleIncomeAndExpenseTransactionsWith(budgetItems: [BudgetItem], transaction: Transaction, account: Account) {
        // Check to see if the category is a budget Item
        for budgetItem in budgetItems {
            if budgetItem.name == transaction.category {
                // This is a BudgetItem
                if transaction.transactionType == TransactionType.income.rawValue {
                    // Remove income
                    
                    // Subtract amount from account
                    AccountController.shared.substractAmountFromAccountWith(amount: transaction.amount, account: account)
                    // Subtract amount from BudgetIem
                    BudgetItemController.shared.substractTotalAllotedAmountFromBudgetItem(amount: transaction.amount, budgetItem: budgetItem)
                } else {
                    // Expense
                    
                    // Add amount to account
                    AccountController.shared.addAmountToAccountWith(amount: transaction.amount, account: account)
                    // Subtract from account
                    BudgetItemController.shared.substractSpentTotalAmountFromBudgetItem(amount: transaction.amount, budgetItem: budgetItem)
                }
            }
        }
    }
    
    func handlePaydayTransaction(transaction: Transaction, account: Account) {
        if transaction.category == nil && transaction.payee == "Payday"{
            // This should be a payday
            AccountController.shared.substractAmountFromAccountWith(amount: transaction.amount, account: account)
        }
    }
    
    func handlePlannedExpense(transaction: Transaction) {
        if transaction.category == nil {
            // TODO: - Implement this
            
        }
    }
    
    /// This function takes a transaction and returns the index value of that transaction out of the TransactionController.shared.transactions array
    func getIntIndex(fortransaction transaction: Transaction) -> Int {
        
        var indexInteger: Int = 0
        let accounts = TransactionController.shared.transactions
        let accountIndex = accounts.index{$0 === transaction}
        guard let index = accountIndex else { return 0 }
        let indexString = String(index)
        let indexInt = Int(indexString)
        guard let intIndex = indexInt else { return 0 }
        indexInteger = intIndex
        return indexInteger
    }
    
    /// This function takes in an array of transactions and returns a single array of Strings contraining "Month Year" for the transactions
    func returnDatesArray(fromArray array: [Transaction]) -> [String] {
        
        var datesArray: [String] = []
        for transaction in array {
            let transactionDate = returnString(fromDate: transaction.date)
            datesArray.append(transactionDate)
        }
        let array = removeDuplicates(fromArray: datesArray)
        return array.sorted(by: { $0 < $1 })
    }
    
    /// This function takes an input of array of Transactions and returns a ordered dictionary of transactions key value pairs of the date/month of the transaction as the key and an array of transactions as the value
    func returnDictionary(fromArray array: [Transaction]) -> [(key: Date, value: [Transaction])] {
        
        var dictionary: [(key: Date, value: [Transaction])]?
        let dictionaryOfArray = Dictionary(grouping:array){ $0.monthYearDate}
        let sortedArray = dictionaryOfArray.sorted(by: { $0.0 > $1.0 })
        dictionary = sortedArray
        guard let finalDictionary = dictionary else { return [] }
        return finalDictionary
    }
        
    func monthYearTuple(fromDate date: Date) -> (Int, Int) {
        let month = Calendar.current.component(.month, from: Date())
        let year = Calendar.current.component(.year, from: Date())
        return (month, year)
    }
}
