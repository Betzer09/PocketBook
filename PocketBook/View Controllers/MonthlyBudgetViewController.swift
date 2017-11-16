//
//  MonthlyBudgetViewController.swift
//  PocketBook
//
//  Created by Laura O'Brien on 11/6/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class MonthlyBudgetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var plannedExpenseLabel: UILabel!
    @IBOutlet weak var amountLeftLabel: UILabel!
    @IBOutlet weak var totalSpentLabel: UILabel!
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var whiteCircle: PieChartView!
    @IBOutlet weak var legendView: UIView!
    
    // MARK: - Properties
    var projectedIncome: Double?
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCategoryTableView), name: Notifications.budgetItemWasUpdatedNotifaction, object: nil)
        updateUI()
        updatePieChartAndLegendView()
        view.setNeedsDisplay()
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadCategoryTableView()
    }
    
    @objc func reloadCategoryTableView() {
        DispatchQueue.main.async {
            self.updateUI()
            self.updatePieChartAndLegendView()
            self.view.setNeedsDisplay()
            self.categoryTableView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func createBugetItemAlertButtonPressed(_ sender: Any) {
        createBudgetItemAlert()
    }
    
    // MARK: - UITableViewDataSource Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BudgetItemController.shared.budgetItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as? CategroyTableViewCell else {return UITableViewCell()}
        
        let budgetItem = BudgetItemController.shared.budgetItems[indexPath.row]
        cell.categoryNameLabel.text = budgetItem.name
        cell.updateCell(budgetItem: budgetItem)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            let budgetItem = BudgetItemController.shared.budgetItems[indexPath.row]
            BudgetItemController.shared.budgetItems.remove(at: indexPath.row)
            BudgetItemController.shared.delete(budgetItem: budgetItem)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentAlertToUpdateMonthlyBudgetItem(atIndexPath: indexPath)
    }
    
    // MARK: - Alerts
    private func createBudgetItemAlert() {
        let budgetItems: [BudgetItem] = BudgetItemController.shared.budgetItems
        // Limit user to 16 monthly budget items
        let numberOfBudgetItems = BudgetItemController.shared.budgetItems.count
        if numberOfBudgetItems >= 16 {
            presentSimpleAlert(controllerToPresentAlert:self, title: "Budget Category Limit", message: "You may only have 16 different budget categories.")
            return
        }
        
        var nameTextField: UITextField!
        var amountTextField: UITextField!
        
        let alertController = UIAlertController(title: "Create A Budget Category", message: "Where is your money going? You may input a maximum of 16 categories. You have \(16 - numberOfBudgetItems) budget catories remaining.", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Name"
            textField.autocapitalizationType = .words
            nameTextField = textField
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Amount"
            textField.keyboardType = .decimalPad
            amountTextField = textField
        }
        
        let createBugetItemAction = UIAlertAction(title: "Add Item", style: .default) { (_) in
            // Create a bugetItem
            
            guard let name = nameTextField.text, let allottedAmount = Double(amountTextField.text!) else {
                // In case they don't enter anything into the textfield
                presentSimpleAlert(controllerToPresentAlert: self, title: "Oops we are missing information!", message: "Okay")
                self.createBudgetItemAlert()
                return
            }
            
            // Check to see if the user is duplicating budget item name
            for budgetItem in budgetItems {
                if budgetItem.name.lowercased() == nameTextField.text?.lowercased() {
                    presentSimpleAlert(controllerToPresentAlert: self, title: "Duplicate Budget Category", message: "That budget category already exists. Please enter another category.")
                    return
                }
            }
            BudgetItemController.shared.createBudgetItemWith(name: name, spentTotal: 0, allottedAmount: allottedAmount, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(createBugetItemAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// This function presents an alert to the user and allows the user to update a monthly budget item
    private func presentAlertToUpdateMonthlyBudgetItem(atIndexPath indexPathSelected: IndexPath) {
        
        var nameTextField: UITextField!
        var allotedAmountTextField: UITextField!
        let budgetItem = BudgetItemController.shared.budgetItems[indexPathSelected.row]
        guard let totalAllotted = budgetItem.totalAllotted else { return }
        
        let alertController = UIAlertController(title: "Update Budget Category", message: "Please update your budget", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.text = budgetItem.name
            textField.autocapitalizationType = .words
            nameTextField = textField
        }
        alertController.addTextField { (textField) in
            textField.text = "\(totalAllotted)"
            allotedAmountTextField = textField
        }
        
        // FIXME:
        //        guard let allottedAmount = Double(StringAllotedAmount) else {
        //            presentSimpleAlert(controllerToPresentAlert: self, title: "Error Updating Budget Item", message: "You have entered an invalid amount")
        //            self.present(alertController, animate: true, completion: nil)
        //            return
        //
        //        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
            
            guard let name = nameTextField.text,
                let allottedAmount = allotedAmountTextField.text,
                let allottedAmountAsDouble = Double(allottedAmount) else { return }
            budgetItem.name = name
            budgetItem.totalAllotted = allottedAmountAsDouble
            guard let totalAllotted = budgetItem.totalAllotted else { return }
            BudgetItemController.shared.updateBudgetWith(name: budgetItem.name , spentTotal: budgetItem.spentTotal, allottedAmount: totalAllotted, budgetItem: budgetItem, completion: { (_) in })
            self.categoryTableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Methods
    
    /// This function adds up the allotted amounts for all planned expenses in the Planned Expense Model Controller
    func addUpPlannedExpenses() -> Double {
        
        var totalPlannedExpenses: Double = 500
        for plannedExpense in PlannedExpenseController.shared.plannedExpenses {
            totalPlannedExpenses += plannedExpense.goalAmount
        }
        return totalPlannedExpenses
    }
    
    /// This function adds up the total of all current monthly budget items
    func addUpTotalSpendOfBudget() -> Double {
        
        var totalSpendOfBudget: Double = 0.0
        for budgetItem in BudgetItemController.shared.budgetItems {
            totalSpendOfBudget += budgetItem.spentTotal
        }
        return totalSpendOfBudget
    }
    
    /// This function updates the monthly budget label
    func updateMonthlyBudgetLabel() {
        //Projected income - plannedExpense
        guard let projectedIncome = projectedIncome else {
            amountLeftLabel.text = "Please enter a projected income amount"
            return
        }
        amountLeftLabel.text = "Amount left to budget this month: $\(projectedIncome - addUpTotalSpendOfBudget())"
    }
    
    // MARK: - UI
    private func updateUI() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        amountTextField.delegate = self
        categoryTableView.estimatedRowHeight = 50
        categoryTableView.rowHeight = UITableViewAutomaticDimension
        
        // TODO: FIX ME - Possibly have label above these three labels that returns the current month
        // FIXME: Make sure that the function addUpPlannedExpenses works once we can add planned expenses
        // the amount should come from the plannedExpenseModelController
        plannedExpenseLabel.text = "Total planned expenses for this month: $\(addUpPlannedExpenses())"
        //Projected income - plannedExpense
       updateMonthlyBudgetLabel()
        // TODO: - FIX ME
        totalSpentLabel.text = "Total Spent of monthly budget: $\(addUpTotalSpendOfBudget() + addUpPlannedExpenses())"
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Setup PieChart
    func updatePieChartAndLegendView() {
        var filteredDictionary: [String: Double] = [:]
        let budgetItems: [BudgetItem] = BudgetItemController.shared.budgetItems
        for budgetItem in budgetItems {
            let name = budgetItem.name
            let amount = budgetItem.spentTotal
            filteredDictionary[name] = amount
        }
        PieChartView.shared.createLegendView(fromView: legendView)
        PieChartView.shared.formatPieChartViewAndLegend(withPieCharView: pieChartView, andLegendView: legendView, usingFilteredDictionary: filteredDictionary)
        PieChartView.shared.formatInnerCircle(fromPieChartView: whiteCircle)
    }
}

// MARK: - Textfield Delegate Functions
extension MonthlyBudgetViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = "$"
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn: "0123456789.").inverted
        let componentSeperatedByCharInSet = string.components(separatedBy: aSet)
        let numberTextField = componentSeperatedByCharInSet.joined(separator: "")
        return string == numberTextField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let string = textField.text else {return false}
        let stringToChange = string.dropFirst()
        
        if textField.text != "$" {
            guard let income = Double(stringToChange) else {
                presentSimpleAlert(controllerToPresentAlert: self, title: "Error", message: "You entered an invalid amount!")
                return false
            }
            // Store the number in the projectedIncome Variable
            projectedIncome = income
            updateMonthlyBudgetLabel()
        }
        textField.resignFirstResponder()
        return false
    }
}


