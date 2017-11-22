//
//  Keys.swift
//  PocketBook
//
//  Created by Michael Meyers on 11/9/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation

struct Keys {
    
    // MARK: - ViewController Identifiers
    static let pieCharVCIdentifier = "pieChart"
    static let budgetLineGraphVCIdentifier = "budgetLineGraph"
    static let plannedExpensesGraphVCIdentifer = "plannedExpensesLineGraph"
    
    // MARK: - Notification Dictionary Keys
    static let timeFrameKey = "timeFrame"
    
    // MARK: - Transaction Model Keys
    static let recordTransactionType = "Transaction"
    static let dateKey = "date"
    static let catagoryKey = "category"
    static let payeeKey = "payee"
    static let transactionTypeKey = "transaction"
    static let amountKey = "amount"
    static let accountTransactionKey = "account"
    static let monthYearDateKey = "monthYearDate"
    
    // MARK: - Account Model Keys
    static let recordAccountType = "Account"
    static let accountTypeKey = "accountType"
    static let accountNameKey = "name"
    static let totalKey = "total"
    
    // MARK: - BudgetItem Model Keys
    static let recordBudgetItemType = "BudgetItem"
    static let spentTotalKey = "spentTotal"
    static let allottedAmountKey = "allottedAmount"
    static let totalAllottedKey = "totalAllotted"
    static let budgetItemNameKey = "name"
    
    // MARK: - Planned Expense Model Keys
    static let recordPlannedExpenseType = "PlannedExpense"
    static let plannedExpenseNameKey = "name"
    static let accountPlannedExpenseKey = "account"
    static let dueDateKey = "dueDate"
    static let initialAmountKey = "initialAmount"
    static let goalAmountKey = "goalAmount"
    /**/    static let amountDepositedKey = "amountDeposited"
    /**/    static let amountWithdrawnKey = "amountWithdrawn"
    static let totalSavedKey = "totalSaved"
    
    // MARK: - Users Model Keys
    static let projectedIncomeKey = "projectedIncome"
    static let recordUsersType = "Users"
    
    // MARK: - User Defaults Keys
    static let dateDictionaryKey = "date"
}
