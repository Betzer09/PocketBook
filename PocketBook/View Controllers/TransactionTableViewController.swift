//
//  TransactionTableViewController.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/8/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class TransactionTableViewController: UITableViewController {
    
    // MARK: - Eventually Delete
    enum TimeFrame: String {
        case pastYear = "Past Year"
        case yearToDate = "Year to Current Date"
        case lastMonth = "Last Month"
        case thisMonth = "This Month"
    }
    
    // MARK: Properties
    var transactions = TransactionController.shared.transactions
    var filteredByTimeFrameTransactions: [Transaction]?
    var filteredByCatagoryTransactions: [Transaction]?
    var timeFrame: String? // FIXME: Add logic
    
    var category: String?
    
    var dots: [UIView] = []
    let calendar = Calendar.autoupdatingCurrent
    var currentYear: Int? {
        let current = calendar.dateComponents([.year, .month], from: Date())
        guard let year = current.year else {return nil}
        return year
    }
    var currentMonth: Int? {
        let current = calendar.dateComponents([.year, .month], from: Date())
        guard let month = current.month else {return nil}
        return month
    }
    
    var timeFrames: [String] {
        var array: [String] = []
        array.append(TimeFrame.pastYear.rawValue)
        array.append(TimeFrame.yearToDate.rawValue)
        array.append(TimeFrame.lastMonth.rawValue)
        array.append(TimeFrame.thisMonth.rawValue)
        array.append("All") // This is the array that I will use to fill the time picker
        return array
    }
    
    var categories: [String] {
        let budgetItems = BudgetItemController.shared.budgetItems
        var names: [String] = [] // This is the array that I will use to fill the categories
        for budgetItem in budgetItems {
            names.append(budgetItem.name)
        }
        let plannedExpenses = PlannedExpenseController.shared.plannedExpenses
        
        for plannedExpense in plannedExpenses {
            names.append(plannedExpense.name)
        }
        return names
    }
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    // MARK: View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: TransactionController.shared.transactionWasUpdatedNotification, object: nil)
    }
    
    @objc func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: Actions
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TransactionController.shared.transactions.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath) as? TransactionTableViewCell ?? TransactionTableViewCell()
        
        cell.transactions = TransactionController.shared.transactions[indexPath.row]
        
        return cell
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let transaction = TransactionController.shared.transactions[indexPath.row]
            TransactionController.shared.transactions.remove(at: indexPath.row)
            TransactionController.shared.delete(transaction: transaction)
        }
    }
    
    // MARK: - Filters
    func filterTransactionsByTimeFrame(){
        
        guard let text = timeFrame else {return}
        var internalFilteredTransactions: [Transaction] = []
        switch text {
        case TimeFrame.pastYear.rawValue:
            for transaction in transactions {
                guard let month = currentMonth,
                    let year = currentYear else {return}
                let calendarDate = calendar.dateComponents([.year, .month], from: transaction.date)
                guard let dateMonth = calendarDate.month,
                    let dateYear = calendarDate.year else {return}
                if dateYear == year {
                    if dateMonth <= month {
                        internalFilteredTransactions.append(transaction)
                    }
                }
                if dateYear == (year - 1) {
                    if dateMonth > month {
                        internalFilteredTransactions.append(transaction)
                    }
                }
            }
        case TimeFrame.yearToDate.rawValue:
            for transaction in transactions {
                guard let month = currentMonth,
                    let year = currentYear else {return}
                let calendarDate = calendar.dateComponents([.year, .month], from: transaction.date)
                guard let dateMonth = calendarDate.month,
                    let dateYear = calendarDate.year else {return}
                if dateYear == year {
                    if dateMonth <= month {
                        internalFilteredTransactions.append(transaction)
                    }
                }
            }
        case TimeFrame.lastMonth.rawValue:
            for transaction in transactions {
                guard let month = currentMonth,
                    let year = currentYear else {return}
                let calendarDate = calendar.dateComponents([.year, .month], from: transaction.date)
                guard let dateMonth = calendarDate.month,
                    let dateYear = calendarDate.year else {return}
                if dateYear == year {
                    if dateMonth == (month - 1) {
                        internalFilteredTransactions.append(transaction)
                    }
                }
            }
        case TimeFrame.thisMonth.rawValue:
            for transaction in transactions {
                guard let month = currentMonth,
                    let year = currentYear else {return}
                let calendarDate = calendar.dateComponents([.year, .month], from: transaction.date)
                guard let dateMonth = calendarDate.month,
                    let dateYear = calendarDate.year else {return}
                if dateYear == year {
                    if dateMonth == month {
                        internalFilteredTransactions.append(transaction)
                    }
                }
            }
        default:
            filteredByTimeFrameTransactions = transactions
        }
        filteredByTimeFrameTransactions = internalFilteredTransactions
    }
    
    func filterTransactionsByCategory() {
        var internalFilteredTransactions: [Transaction] = []
        guard let name = category,
            let filteredTransactions = filteredByTimeFrameTransactions else {return}
        for transaction in filteredTransactions {
            if transaction.catagory == name {
                internalFilteredTransactions.append(transaction)
            }
        }
        filteredByCatagoryTransactions = internalFilteredTransactions
    }
    
    // MARK: - Methods
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toTransactionDVC" {
            
            guard let destinationVC = segue.destination as? TransactionsDetailViewController,
                let indexPath = tableView.indexPathForSelectedRow else { return }
            let transaction = TransactionController.shared.transactions[indexPath.row]
            
            destinationVC.transaction = transaction
        }
    }
}

