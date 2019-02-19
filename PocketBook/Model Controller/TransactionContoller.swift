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
    func createTransactionWith(date: Date, monthYearDate: Date, category: String?, payee: String, transactionType: TransactionType, amount: Double, account: String, completion: ((Transaction) -> Void)? = {_ in}) {
        
        let transaction = Transaction(date: date, monthYearDate: returnFormattedDate(date: monthYearDate), category: category, payee: payee, transactionType: transactionType.rawValue, amount: amount, account: account)
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
        transaction.account = account.removeWhiteSpaces()
        
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
    func delete(transaction: Transaction, removeFromSourceOfTruth: Bool = false, completion: @escaping(_ success: Bool) -> Void = {_ in}) {
        
        cloudKitManager.deleteRecordWithID(transaction.recordID) { (_, error) in
            
            if let error = error {
                print("Error deleting Transaction: \(error.localizedDescription) in file: \(#file)")
                completion(false)
                return
            }
            
            if removeFromSourceOfTruth {
                guard let index = self.transactions.firstIndex(of: transaction) else {completion(false) ;return}
                self.transactions.remove(at: index)
            }
            
            guard let account = AccountController.shared.accounts.first(where: { $0.name.removeWhiteSpaces() == transaction.account.removeWhiteSpaces() })
                else { completion(false) ;return }
            
            let budgetItems = BudgetItemController.shared.budgetItems
            
            if budgetItems.contains(where: { $0.name.removeWhiteSpaces() == transaction.category?.removeWhiteSpaces() }) {
                self.handleIncomeAndExpenseTransactionsWith(budgetItems: budgetItems, transaction: transaction, account: account, completion: { (complete) in
                    guard complete else {completion(false) ;return}
                    completion(true)
                })
            } else if transaction.category == nil && transaction.payee == "Payday"{
                self.handlePaydayTransaction(transaction: transaction, account: account)
                completion(true)
            } else if PlannedExpenseController.shared.plannedExpenses.contains(where: { $0.name == transaction.category }) {
                self.handlePlannedExpenseDepositDeletion(category: transaction.payee, transaction: transaction.amount, account: account)
                completion(true)
            } else {
                // This is a account transfer transaction
                self.handleAccountTransferTransactionWith(transaction: transaction)
                completion(true)
            }
            
        }
    }
    
    /// Takes in the payer and splits the accounts up.
    private func handleAccountTransferTransactionWith(transaction: Transaction) {
        // checkings -> savings
        if transaction.payee.contains("->") {
            // subtract amount from transaction account
            guard let firstAccount = AccountController.shared.accounts.first(where: { $0.name.removeWhiteSpaces() == transaction.account.removeWhiteSpaces() }) else {return}
            AccountController.shared.substractAmountFromAccountWith(amount: transaction.amount, account: firstAccount)
            
            // increment index by one to remove the space on the left side
        
            let secondHalfOfString = transaction.payee.split(whereSeparator: { $0 == "-" })
            guard let secondAccountSubString = secondHalfOfString.first, let secondAccount = AccountController.shared.accounts.first(where: { $0.name.removeWhiteSpaces() == String(secondAccountSubString).removeWhiteSpaces() }) else {return}
            
            AccountController.shared.addAmountToAccountWith(amount: transaction.amount, account: secondAccount)
        }
    }
    
    func handlePlannedExpenseDepositDeletion(category: String, transaction amount: Double, account: Account) {
        guard let plannedexpense = PlannedExpenseController.shared.plannedExpenses.first(where: { $0.name == category })
            else {return}
        
        AccountController.shared.addAmountToAccountWith(amount: amount, account: account) { (complete) in
            guard complete else {return}
            PlannedExpenseController.shared.subtractAmountoTotalDeposited(amount: amount, plannedexpense: plannedexpense)
        }
    }
    func handleIncomeAndExpenseTransaction(transactiontype: TransactionType, amount: Double, account: Account, budgetItem: BudgetItem) {
        if transactiontype == TransactionType.income {
            AccountController.shared.addAmountToAccountWith(amount: amount, account: account) { (complete) in
                guard complete else {return}
                BudgetItemController.shared.addTotalAllotedAmountToBudgetItem(amount: amount, budgetItem: budgetItem)
            }
        } else {
            AccountController.shared.substractAmountFromAccountWith(amount: amount, account: account) { (complete) in
                guard complete else {return}
                BudgetItemController.shared.addSpentTotalAmountToBudgetItem(amount: amount, budgetItem: budgetItem)
            }
        }
    }
    
    func handlePlannedExpenseTransactionWtih(plannedexpense name: String, amount: Double, account: Account) {
        guard let plannedexpense = PlannedExpenseController.shared.plannedExpenses.first(where: { $0.name == name }) else {return}
        AccountController.shared.substractAmountFromAccountWith(amount: amount, account: account) { (complete) in
            guard complete else {return}
            PlannedExpenseController.shared.addAmountToTotalDeposited(amount: amount, plannedexpense: plannedexpense)
        }
    }
    
    func transferMoneyTo(account: Account, fromAccount: Account, withTransfer amount: Double, completion: @escaping (_ success: Bool) -> Void) {
        // add amount to account
        AccountController.shared.addAmountToAccountWith(amount: amount, account: account) { (success) in
            guard success else {completion(false); return}            
            TransactionController.shared.createTransactionWith(date: Date(), monthYearDate: Date(), category: nil, payee: "\(fromAccount.name ) -> \(account.name)", transactionType: .income, amount: amount, account: account.name, completion: { (transaction) in
                AccountController.shared.substractAmountFromAccountWith(amount: amount, account: fromAccount, completion: { (success) in
                    completion(true)
                })
            })
        }
    }
    
    // MARK: - Fetch Data from CloudKit
    func fetchTransActionsFromCloudKit(completion: @escaping(_ complete: Bool) -> Void = {_ in}) {
        
        // Get all of the accounts
        let predicate = NSPredicate(value: true)
        
        // Create a query
        let query = CKQuery(recordType: Keys.recordTransactionType, predicate: predicate)
        
        // Fetch the data form cloudkit
        privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
            
            // Check for an errror
            if let error = error {
                print("Error fetching the Accounts Data: \(error.localizedDescription) in file: \(#file)")
                completion(false)
            }
            
            guard let records = records else {completion(false) ;return}
            
            // Send the accounts through the cloudKit Initilizer
            let transaction = records.compactMap( {Transaction(cloudKitRecord: $0)})
            
            self.transactions = transaction
            completion(true)
        }
    }
    
    // MARK: - Methods
    func handlePlannedExpense(transaction: Transaction, account: Account) {
        var transactionType: TransactionType
        
        if transaction.transactionType == TransactionType.income.rawValue {
            transactionType = TransactionType.income
        } else {
            transactionType = TransactionType.expense
        }
        
        createTransactionWith(date: transaction.date, monthYearDate: transaction.monthYearDate, category: nil, payee: transaction.payee, transactionType: transactionType, amount: transaction.amount, account: account.name)
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

    
    // MARK: - Functions
    
    private func handleIncomeAndExpenseTransactionsWith(budgetItems: [BudgetItem], transaction: Transaction, account: Account, completion: @escaping (_ complete: Bool) -> Void) {

        // Check to see if the category is a budget Item
        for budgetItem in budgetItems {
            if budgetItem.name == transaction.category {
                // This is a BudgetItem
                if transaction.transactionType == TransactionType.income.rawValue {
                    // Remove income
                    
                    // Subtract amount from account
                    AccountController.shared.substractAmountFromAccountWith(amount: transaction.amount, account: account) { (complete) in
                        guard complete else {return}
                        // Subtract amount from BudgetIem
                        BudgetItemController.shared.substractTotalAllotedAmountFromBudgetItem(amount: transaction.amount, budgetItem: budgetItem)
                        completion(true)
                    }
                } else {
                    // Expense
                    
                    // Add amount to account
                    AccountController.shared.addAmountToAccountWith(amount: transaction.amount, account: account) { (complete) in
                        guard complete else {return}
                        // Subtract from account
                        BudgetItemController.shared.substractSpentTotalAmountFromBudgetItem(amount: transaction.amount, budgetItem: budgetItem)
                        completion(true)
                    }
                }
            }
        }
    }
    
    private func handlePaydayTransaction(transaction: Transaction, account: Account) {
        AccountController.shared.substractAmountFromAccountWith(amount: transaction.amount, account: account)
    }
    
    private func handlePlannedExpense(transaction: Transaction) {
        if transaction.category == nil {
            
        }
    }
    
}
