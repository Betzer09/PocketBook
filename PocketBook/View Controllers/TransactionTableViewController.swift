//
//  TransactionTableViewController.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/8/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class TransactionTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        self.setUpInitialTableView()
        self.timePicker.dataSource = self
        self.timePicker.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: TransactionController.shared.transactionWasUpdatedNotification, object: nil)
       
    }
    
    @objc func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Eventually Delete
    enum TimeFrame: String {
        case all = "All"
        case thisMonth = "This Month"
        case lastMonth = "Last Month"
        case yearToDate = "Year to Current Date"
        case pastYear = "Past Year"
    }
    
    // MARK: Properties
    
    var filteredTransactions: [Transaction] = [] // SOURCE OF TRUTH - filtered transactions
    
    // UIPicker Properties: All properties that are used by the UIPickers
    var categorySelection: String? // Value selected by UIPicker. This updates each time a value from the picker is selected
    var timeframeSelection: String?  // Value selected by UIPicker. This updates each time a value from the picker is selected
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
    
    var categories: [String] {
        let budgetItems = BudgetItemController.shared.budgetItems
        var names: [String] = []
        for budgetItem in budgetItems {
            names.append(budgetItem.name)
        }
        let plannedExpenses = PlannedExpenseController.shared.plannedExpenses
        for plannedExpense in plannedExpenses {
            names.append(plannedExpense.name)
        }
        return names
    }
    
    
    
    // MARK: - Actions
    
    func setUpInitialTableView() {
        self.filteredTransactions = TransactionController.shared.transactions
        self.tableView.reloadData()
    }

    // Segmented Control Buttons Selected
    @IBAction func SegmentedControlButtonPressed(_ sender: UISegmentedControl) {
        
        let filteredByTimeFrame = Set(filterTransactionsByTimeFrame())
        let filterByCategory = Set(filterTransactionsByCategory())
        let filterByTransactionType = Set(filterTransactionsByTransactionType())
        let filterAllSets = filteredByTimeFrame.intersection(filterByCategory).intersection(filterByTransactionType)
        let combinedTimeframeTransactionsSet = Array(filterAllSets)
        let combinedTimeframeTransactionsArray = Array(combinedTimeframeTransactionsSet)
        self.filteredTransactions = combinedTimeframeTransactionsArray
        self.tableView.reloadData()
    }
    
    /// This function checks to see which segmented control is currently pressed and returns a string value matching the segmented control
    func checkWhichControlIsPressed() -> String {
        
        var currentSegmentedControlSelection = String()
        if segmentedControl.selectedSegmentIndex == 0 {
            currentSegmentedControlSelection = "All"
        } else if
            segmentedControl.selectedSegmentIndex == 1 {
            currentSegmentedControlSelection = "Income"
        } else {
            currentSegmentedControlSelection = "Expense"
        }
        return currentSegmentedControlSelection
    }
    
    
    
    // MARK: - UIPicker
    
    func setUpPicker() -> ([String], [String]) {
        
        let times: [TimeFrame] = [.all, .thisMonth, .lastMonth, .yearToDate, .pastYear, ]
        
        var transactionCategories: [String] = AccountController.shared.accounts.map({$0.name}) + PlannedExpenseController.shared.plannedExpenses.map({ $0.name })
        transactionCategories.insert("All", at: 0)
   
        
        let combined: ([String], [String]) = (times.map({$0.rawValue}), transactionCategories)
        
        return combined
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0 {
            return setUpPicker().0.count
        } else {
            return setUpPicker().1.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 0 {
            return setUpPicker().0[row]
        } else {
            return  setUpPicker().1[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let times: [TimeFrame] = [.all, .thisMonth, .lastMonth, .yearToDate, .pastYear, ]
        
        let selectedTimeFrame = pickerView.selectedRow(inComponent: 0)
        let selectedCategory = pickerView.selectedRow(inComponent: 1)
        
        var transactionCategories: [String] = AccountController.shared.accounts.map({$0.name}) + PlannedExpenseController.shared.plannedExpenses.map({ $0.name })
        transactionCategories.insert("All", at: 0)
        let timesStringArray = times.map({$0.rawValue})
        let combinedPickerArrays = [transactionCategories, timesStringArray]
        
        let categorySelection = combinedPickerArrays[0][selectedCategory]
        self.categorySelection = categorySelection
        
        let filteredTimeFrame = Set(filterTransactionsByTimeFrame())
        let filterCategory = Set(filterTransactionsByCategory())
        let filterTransactionType = Set(filterTransactionsByTransactionType())
        let filterAll = filteredTimeFrame.intersection(filterCategory).intersection(filterTransactionType)
        let combinedCategoryTransactionsSet = Array(filterAll)
        let combinedCatetoryTransactionsArray = Array(combinedCategoryTransactionsSet)
        
        self.filteredTransactions = combinedCatetoryTransactionsArray
        self.tableView.reloadData()
        
        let timeframeSelection = combinedPickerArrays[1][selectedTimeFrame]
        self.timeframeSelection = timeframeSelection
        
        let filteredByTimeFrame = Set(filterTransactionsByTimeFrame())
        let filterByCategory = Set(filterTransactionsByCategory())
        let filterByTransactionType = Set(filterTransactionsByTransactionType())
        let filterAllSets = filteredByTimeFrame.intersection(filterByCategory).intersection(filterByTransactionType)
        let combinedTimeframeTransactionsSet = Array(filterAllSets)
        let combinedTimeframeTransactionsArray = Array(combinedTimeframeTransactionsSet)
        self.filteredTransactions = combinedTimeframeTransactionsArray
        self.tableView.reloadData()
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label: UILabel!
        
        if component == 0 {
            label = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 44))
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 0
            label.textAlignment = .center
            label.sizeToFit()
            label.text = setUpPicker().0[row]
        } else {
            label = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 43))
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 2
            label.textAlignment = .center
            label.sizeToFit()
            label.text = setUpPicker().1[row]
        }
        
        return label
        
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 43
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredTransactions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath) as? TransactionTableViewCell ?? TransactionTableViewCell()
        
        cell.transactions = filteredTransactions[indexPath.row]
        
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
    
    func filterTransactionsByTimeFrame() -> [Transaction] {
        
        guard let text = timeframeSelection else { return [] }
        var internalFilteredTransactions: [Transaction] = []
        let allTransactions = TransactionController.shared.transactions
        print("TIMEFRAME: \(timeframeSelection)")
        switch text {
        case TimeFrame.pastYear.rawValue:
            for transaction in allTransactions {
                guard let month = currentMonth,
                    let year = currentYear else { return [] }
                let calendarDate = calendar.dateComponents([.year, .month], from: transaction.date)
                guard let dateMonth = calendarDate.month,
                    let dateYear = calendarDate.year else { return [] }
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
            for transaction in allTransactions {
                guard let month = currentMonth,
                    let year = currentYear else { return [] }
                let calendarDate = calendar.dateComponents([.year, .month], from: transaction.date)
                guard let dateMonth = calendarDate.month,
                    let dateYear = calendarDate.year else { return [] }
                if dateYear == year {
                    if dateMonth <= month {
                        internalFilteredTransactions.append(transaction)
                    }
                }
            }
        case TimeFrame.lastMonth.rawValue:
            for transaction in allTransactions {
                guard let month = currentMonth,
                    let year = currentYear else { return [] }
                let calendarDate = calendar.dateComponents([.year, .month], from: transaction.date)
                guard let dateMonth = calendarDate.month,
                    let dateYear = calendarDate.year else { return [] }
                if dateYear == year {
                    if dateMonth == (month - 1) {
                        internalFilteredTransactions.append(transaction)
                    }
                }
            }
        case TimeFrame.thisMonth.rawValue:
            for transaction in allTransactions {
                guard let month = currentMonth,
                    let year = currentYear else { return [] }
                let calendarDate = calendar.dateComponents([.year, .month], from: transaction.date)
                guard let dateMonth = calendarDate.month,
                    let dateYear = calendarDate.year else { return [] }
                if dateYear == year {
                    if dateMonth == month {
                        internalFilteredTransactions.append(transaction)
                    }
                }
            }
        default:
            internalFilteredTransactions = allTransactions
        }
        return internalFilteredTransactions
    }
    
    func filterTransactionsByCategory() -> [Transaction] {
        var internalFilteredTransactions: [Transaction] = []
        let allTransactions = TransactionController.shared.transactions
        print("CATEGORY: \(categorySelection)")
        
        for transaction in allTransactions {
            if categorySelection == "All" {
                 internalFilteredTransactions = allTransactions
            } else if transaction.catagory == categorySelection {
                internalFilteredTransactions.append(transaction)
            }
        }
        return internalFilteredTransactions
    }
    
    func filterTransactionsByTransactionType() -> [Transaction] {
        var internalFilteredTransactions: [Transaction] = []
        let selectedControl = checkWhichControlIsPressed()
        let allTransactions = TransactionController.shared.transactions
        print("TRANSACTION: \(checkWhichControlIsPressed())")
        for transaction in allTransactions {
            if selectedControl == "All" {
                internalFilteredTransactions = allTransactions
            } else if transaction.transactionType == selectedControl {
                internalFilteredTransactions.append(transaction)
            }
        }
        return internalFilteredTransactions
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

