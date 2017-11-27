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
    @IBOutlet weak var plannedExpenseTotalLabel: UILabel!
    @IBOutlet weak var totalBudgetedIncomLabel: UILabel!
    @IBOutlet weak var incomeNotCurrentlyBudgetLabel: UILabel!
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var whiteCircle: PieChartView!
    @IBOutlet weak var legendView: UIView!
    @IBOutlet weak var plannedExpensesView: UIView!
    @IBOutlet weak var projectedIncomeView: UIView!
    @IBOutlet weak var totalBudgetedIncomeView: UIView!
    @IBOutlet weak var incomeNotCurrentlyBudgetedView: UIView!
    
    
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
    @objc private func createBudgetItemAlert() {
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
    
    /// This function adds up the total of all current monthly budget items
    func addUpTotalSpendOfBudget() -> Double {
        
        var totalSpendOfBudget: Double = 0.0
        for budgetItem in BudgetItemController.shared.budgetItems {
            totalSpendOfBudget += budgetItem.spentTotal
        }
        return totalSpendOfBudget + PlannedExpenseController.shared.calculateTotalMonthlyContribution()
    }
    
    /// This function updates the monthly budget label
    func updateMonthlyBudgetLabel() {
        
        //Projected income - plannedExpense
        guard let projectedIncome = projectedIncome else {
            totalBudgetedIncomLabel.text = "$0.00"
            return
        }
        totalBudgetedIncomLabel.text = "\(formatNumberToString(fromDouble: projectedIncome - addUpTotalSpendOfBudget()))"
    }
    
    // MARK: - UI
    private func updateUI() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        createPlusButton()
        configureViewsToLookLikeCells()
        
        amountTextField.delegate = self
        categoryTableView.estimatedRowHeight = 50
        categoryTableView.rowHeight = UITableViewAutomaticDimension
    
        // Update all three labels in the view below the budget items
        plannedExpenseTotalLabel.text = "\(formatNumberToString(fromDouble: PlannedExpenseController.shared.calculateTotalMonthlyContribution()))"
        updateMonthlyBudgetLabel()
        incomeNotCurrentlyBudgetLabel.text = "\(formatNumberToString(fromDouble: addUpTotalSpendOfBudget() + PlannedExpenseController.shared.calculateTotalMonthlyContribution()))"
        
        // FIXME: Set up amountTextfield to display user information
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // This is to make the views look like cells
    func configureViewsToLookLikeCells() {
        self.plannedExpensesView.layer.borderWidth = 1
        self.plannedExpensesView.layer.borderColor = UIColor.gray.cgColor

        
        self.totalBudgetedIncomeView.layer.borderWidth = 1
        self.totalBudgetedIncomeView.layer.borderColor = UIColor.gray.cgColor

        
        self.incomeNotCurrentlyBudgetedView.layer.borderWidth = 1
        self.incomeNotCurrentlyBudgetedView.layer.borderColor = UIColor.gray.cgColor
        
        self.projectedIncomeView.layer.borderWidth = 1
        self.projectedIncomeView.layer.borderColor = UIColor.gray.cgColor

    }
    
    func createPlusButton() {
        let button = UIButton()
        button.clipsToBounds = true
        button.setImage(#imageLiteral(resourceName: "plusButton"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(createBudgetItemAlert), for: UIControlEvents.touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
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
        
        print("USERS: \(UsersController.shared.users)")
        guard let string = textField.text else { return false }
        let stringToChange = string.dropFirst()
        
        if textField.text != "$" {
            guard let income = Double(stringToChange) else {
                presentSimpleAlert(controllerToPresentAlert: self, title: "Error", message: "You entered an invalid amount!")
                return false
            }
            
            // Store the number in the projectedIncome Variable
            projectedIncome = income
            UsersController.shared.createUser(withProjectedIncome: income, completion: nil)
            updateMonthlyBudgetLabel()
        }
        textField.resignFirstResponder()
        return false
    }
}


