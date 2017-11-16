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
    
    // MARK: - Properties
    var projectedIncome: Double?
    
    // MARK: - Outlets
    @IBOutlet weak var plannedExpenseLabel: UILabel!
    @IBOutlet weak var amountLeftLabel: UILabel!
    @IBOutlet weak var totalSpentLabel: UILabel!
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var whiteCircle: PieChartView!
    @IBOutlet weak var legendView: UIView!
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCategoryTableView), name: Notifications.budgetItemWasUpdatedNotifaction, object: nil)
        updateUI()
        updatePieChartAndLegendView()
        view.setNeedsDisplay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        reloadCategoryTableView()
    }
    
    // MARK: - Notification Methods
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
        createBugetItemAlert()
    }
    
    // MARK: - UITableViewDataSource Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BudgetItemController.shared.budgetItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "categroyCell", for: indexPath) as? CategroyTableViewCell else {return UITableViewCell()}
        
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
    
    // MARK: - Alerts
    private func createBugetItemAlert() {
        
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
                self.createBugetItemAlert()
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
    
    // MARK: - UI
    private func updateUI() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        amountTextField.delegate = self
        categoryTableView.estimatedRowHeight = 50
        categoryTableView.rowHeight = UITableViewAutomaticDimension
        
        // TODO: FIX ME
        // the amount should come from the plannedExpenseModelController
        plannedExpenseLabel.text = "Planned Exspense for the Month: 1500.32"
        //Projected income - plannedExpense
        amountLeftLabel.text = "$532 Left to buget"
        // TODO: - FIX ME
        totalSpentLabel.text = "Total Spent of Budget $300"
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
        }
        textField.resignFirstResponder()
        return false
    }
}


