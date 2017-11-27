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
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    // MARK: - Customize Segmented Control
    func customizeSegmentedControl() {
        segmentedControl.customizeSegmentedControl()
    }
    
    // MARK: View Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        setUpTableView()
        self.customizeSegmentedControl()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.picker.dataSource = self
        self.picker.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: Notifications.transactionWasUpdatedNotification, object: nil)
        self.categorySelection = "All"
        self.timeframeSelection = "All"
        self.setUpTableView()
        self.customizeSegmentedControl()
    }
    
    @objc func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: Properties
    var filteredTransactions: [Transaction] = [] // SOURCE OF TRUTH - Array contains all transactions
    
    // UIPicker Properties: All properties that are used by the UIPickers
    var categorySelection: String? // Value selected by UIPicker. This updates each time a value from the picker is selected
    var timeframeSelection: String?  // Value selected by UIPicker. This updates each time a value from the picker is selected
    
    // MARK: - Actions
    
    /// This function is run when the view first loads and the user hasn't made any selections
    func setUpTableView() {
        guard let timeframeSelection = timeframeSelection,
            let categorySelection = categorySelection else {return}
        let transactions = TransactionController.shared.transactions
        let transactionType = checkWhichControlIsPressed(segmentedControl: segmentedControl, type1: .all, type2: .income, type3: .expense)
        let filteredByTransactionType = filterByTransactionType(byThisType: transactionType, forThisArray: transactions)
        let filteredByTimeFrame = filterByTimeFrame(withTimeVariable: timeframeSelection, forThisArray: filteredByTransactionType)
        let filteredByCategory = filterByCategoryIntoArray(forCategory: categorySelection, forThisArray: filteredByTimeFrame)
        let filteredByDate = filteredByCategory.sorted(by: { $0.date > $1.date })
        self.filteredTransactions = filteredByDate
        self.tableView.reloadData()
    }
    
    // Segmented Control Buttons Selected
    @IBAction func SegmentedControlButtonPressed(_ sender: UISegmentedControl) {
        setUpTableView()
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
        
        // Set up the controls that the user will use to filter tableview
        let times: [TimeFrame] = [.all, .thisMonth, .lastMonth, .yearToDate, .pastYear, ]
        let selectedTimeFrame = pickerView.selectedRow(inComponent: 0)
        let selectedCategory = pickerView.selectedRow(inComponent: 1)
        var transactionCategories: [String] = AccountController.shared.accounts.map({$0.name}) + PlannedExpenseController.shared.plannedExpenses.map({ $0.name })
        transactionCategories.insert("All", at: 0)
        let timesStringArray = times.map({$0.rawValue})
        let combinedPickerArrays = [transactionCategories, timesStringArray] // Source of truth for pickerview
        
        let categorySelection = combinedPickerArrays[0][selectedCategory]
        self.categorySelection = categorySelection
        setUpTableView()
        
        let timeframeSelection = combinedPickerArrays[1][selectedTimeFrame]
        self.timeframeSelection = timeframeSelection
        setUpTableView()
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
    
    // MARK: - Tableview
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = TransactionController.shared.returnDictionary(fromArray: filteredTransactions)[section].0
        return returnString(fromDate: date)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return TransactionController.shared.returnDictionary(fromArray: filteredTransactions).count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TransactionController.shared.returnDictionary(fromArray: filteredTransactions)[section].1.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath) as? TransactionTableViewCell ?? TransactionTableViewCell()
        let transaction = TransactionController.shared.returnDictionary(fromArray: filteredTransactions)[indexPath.section].1[indexPath.row]
        cell.transactions = transaction
        
        // Change colors of cell labels
        guard let transactionType = cell.transactions?.transactionType else { return cell }
        switch transactionType {
        case TransactionType.expense.rawValue:
            cell.amountLabel.textColor = .red
        default:
            cell.amountLabel.textColor = .green
        }
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let numberOfRowsInSection = TransactionController.shared.returnDictionary(fromArray: filteredTransactions)[indexPath.section].1.count
            let transaction = TransactionController.shared.returnDictionary(fromArray: filteredTransactions)[indexPath.section].1[indexPath.row]
            let intIndex = TransactionController.shared.getIntIndex(fortransaction: transaction)
            TransactionController.shared.transactions.remove(at: intIndex)
            TransactionController.shared.delete(transaction: transaction)
            filteredTransactions = TransactionController.shared.transactions
            
            // Delete selected row/section
            if numberOfRowsInSection == 1 {
                tableView.deleteSections([indexPath.section ], with: .automatic)
            } else {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toTransactionDVC" {
            guard let destinationVC = segue.destination as? TransactionsDetailViewController,
                let indexPath = tableView.indexPathForSelectedRow else { return }
            let transaction = TransactionController.shared.returnDictionary(fromArray: filteredTransactions)[indexPath.section].1[indexPath.row]
            destinationVC.transaction = transaction
        }
    }
}







