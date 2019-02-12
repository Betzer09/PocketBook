//
//  MonthlyBudgetViewController.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/7/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class MonthlyBudgetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var categoryTableView: UITableView!
    
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var totalBudgetedIncomLabel: UILabel!
    @IBOutlet weak var incomeNotCurrentlyBudgetLabel: UILabel!
    
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var legendView: UIView!
    
    @IBOutlet weak var projectedIncomeView: UIView!
    @IBOutlet weak var totalBudgetedIncomeView: UIView!
    @IBOutlet weak var incomeNotCurrentlyBudgetedView: UIView!
    
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var whiteCircle: PieChartView!
    
    @IBOutlet weak var noDataImage: UIImageView!
    
    // MARK: - Notifications
    
    // MARK: - Properties
    var projectedIncome: Double = 0.0 {
        didSet {
            NotificationCenter.default.post(name: Notifications.projectedIncomeWasUpdatedNotification, object: nil)
        }
    }
    
    let hasLaunchedKey = "ProjectedIncomeHasBeenCreated"
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        addPropertyObservers()
        updatePieChartAndLegendView()
        updateIncomeNotCurrentlyBudgetedTitleLabel()
        view.setNeedsDisplay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        noDataImageSetup()
        reloadCategoryTableViewAndUI()
    }
    
    func noDataImageSetup() {
        if BudgetItemController.shared.budgetItems.count == 0 {
            noDataImage.isHidden = false
        } else {
            noDataImage.isHidden = true
        }
    }
    
    // MARK: - Actions
    
    @IBAction func createBugetItemAlertButtonPressed(_ sender: Any) {
        createBudgetItemAlert()
    }
    
    // MARK: - UITableViewDataSource Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BudgetItemController.shared.budgetItems.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == BudgetItemController.shared.budgetItems.count {
            
            // This is the last cell
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "savingsGoalCell", for: indexPath) as? MonthlyBudgetStaticSavingsGoalCustomTableViewCell else {return UITableViewCell()}
            
            cell.updateCell()
            
            return cell
            
        } else {
            
            // These are the normal budget item cells
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as? CategroyTableViewCell else {return UITableViewCell()}
            
            let budgetItem = BudgetItemController.shared.budgetItems[indexPath.row]
            cell.categoryNameLabel.text = budgetItem.name
            cell.updateCell(budgetItem: budgetItem)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            let budgetItem = BudgetItemController.shared.budgetItems[indexPath.row]
            BudgetItemController.shared.budgetItems.remove(at: indexPath.row)
            BudgetItemController.shared.delete(budgetItem: budgetItem)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentBudgetItemUpdateOptionActionSheetOn(indexpath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Alerts
    @objc private func createBudgetItemAlert() {
        let budgetItems: [BudgetItem] = BudgetItemController.shared.budgetItems
        // Limit user to 16 monthly budget items
        let numberOfBudgetItems = budgetItems.count
        if numberOfBudgetItems >= 16 {
            presentSimpleAlert(controllerToPresentAlert:self, title: "Budget Category Limit", message: "You may only have 16 different budget categories.")
            return
        }
        
        var nameTextField: UITextField!
        var amountTextField: UITextField!
        
        let alertController = UIAlertController(title: "Create A Budget Category", message: "Where is your money going? You may input a maximum of 16 categories. You have \(16 - numberOfBudgetItems) budget catories remaining.", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "ex: Gas, Rent, Food"
            textField.autocorrectionType = UITextAutocorrectionType.yes
            textField.autocapitalizationType = .words
            nameTextField = textField
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "ex: 200"
            textField.keyboardType = .decimalPad
            amountTextField = textField
        }
        
        let createBugetItemAction = UIAlertAction(title: "Add Item", style: .default) { (_) in
            // Create a bugetItem
            
            guard let name = nameTextField.text, let allottedAmount = Double(amountTextField.text!) else {
                // In case they don't enter anything into the textfield
                presentSimpleAlert(controllerToPresentAlert: self, title: "Warning", message: "Both fields are required!")
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
            self.reloadCategoryTableViewAndUI()
            self.noDataImageSetup()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(createBugetItemAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    /// Allows the user to decide if they want to update the total amount budgeted or the amount they've spent.
    private func presentBudgetItemUpdateOptionActionSheetOn(indexpath: IndexPath) {
        let budgetItem = BudgetItemController.shared.budgetItems[indexpath.row]
        let alert = UIAlertController(title: "Update \"\(budgetItem.name)\" Category", message: "Choose \"Total Spent\" if your budget is incorrect, or choose \"Total Allotted\" to update the max amount you would be willing to pay in a budget category.", preferredStyle: .actionSheet)
        
        let btnBudgetName = UIAlertAction(title: "Update Name", style: .default) { (_) in
            self.presentUpdateBudgetNameAlertAt(indexpath: indexpath)
        }
        
        let btnTotalSpent = UIAlertAction(title: "Total Spent", style: .default) { (_) in
            self.presentUpdateTotalSpentAlertAt(indexpath: indexpath)
        }
        
        let btnAmountAlloted = UIAlertAction(title: "Total Allotted", style: .default) { (_) in
            self.presentUpdateTotalAllottedAt(indexpath: indexpath)
        }
        
        let btnCancel = UIAlertAction(title: "Cancel" , style: .cancel, handler: nil)
        
        alert.addAction(btnTotalSpent)
        alert.addAction(btnAmountAlloted)
        alert.addAction(btnBudgetName)
        alert.addAction(btnCancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func presentUpdateBudgetNameAlertAt(indexpath: IndexPath) {
        let alert = UIAlertController(title: "Update Budget Name", message: "", preferredStyle: .alert)
        let budgetItem = BudgetItemController.shared.budgetItems[indexpath.row]
        
        var txtNamefield: UITextField!
        
        alert.addTextField { (textField) in
            textField.text = budgetItem.name
            textField.autocapitalizationType = .words
            textField.autocorrectionType = UITextAutocorrectionType.yes
            txtNamefield = textField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
            guard let newName = txtNamefield.text, !newName.isEmpty,  let totalAllotted = budgetItem.totalAllotted else {
                presentSimpleAlert(controllerToPresentAlert: self, title: "Warning", message: "We couldn't update your Budget because the field is empty")
                return
            }
            BudgetItemController.shared.updateBudgetWith(name: budgetItem.name , spentTotal: budgetItem.spentTotal, allottedAmount: totalAllotted, budgetItem: budgetItem, completion: { (_) in
                self.reloadCategoryTableViewAndUI()
            })
        }
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        self.present(alert, animated: true, completion: nil)

    }
    
    private func presentUpdateTotalSpentAlertAt(indexpath: IndexPath) {
        let alert = UIAlertController(title: "Update Total Spent", message: "This should be the amount you think you've spent this month, you should only change this number if your 100% confident it's wrong.", preferredStyle: .alert)
        let budgetItem = BudgetItemController.shared.budgetItems[indexpath.row]
        
        var txtTotalSpent: UITextField!
        
        alert.addTextField { (textField) in
            textField.text = "\(budgetItem.spentTotal)"
            textField.keyboardType = .decimalPad
            txtTotalSpent = textField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .destructive) { (_) in
            guard let totalSpent = txtTotalSpent.text, let spentTotaltAsDouble = Double(totalSpent)else {
                    presentSimpleAlert(controllerToPresentAlert: self, title: "Warning", message: "We couldn't update your Budget because you enter an invalid amount.")
                    return
            }
            BudgetItemController.shared.updateBudgetWith(name: budgetItem.name , spentTotal: spentTotaltAsDouble, allottedAmount: budgetItem.allottedAmount, budgetItem: budgetItem, completion: { (_) in
                self.reloadCategoryTableViewAndUI()
            })
        }
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    private func presentUpdateTotalAllottedAt(indexpath: IndexPath) {
        let alert = UIAlertController(title: "Update Total Allotted", message: "This should be the MAX you're willing to spend in a certain category per month.", preferredStyle: .alert)
        let budgetItem = BudgetItemController.shared.budgetItems[indexpath.row]
        
        var txtTotalAlloted: UITextField!
        
        alert.addTextField { (textField) in
            guard let totalAllotted = budgetItem.totalAllotted else {fatalError("No amount has been allotted.")}
            textField.text = "\(totalAllotted)"
            textField.keyboardType = .decimalPad
            txtTotalAlloted = textField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .destructive) { (_) in
            guard let totalAlloted = txtTotalAlloted.text, let totalAllotedAsDouble = Double(totalAlloted)else {
                presentSimpleAlert(controllerToPresentAlert: self, title: "Warning", message: "We couldn't update your Budget because you enter an invalid amount.")
                return
            }
            BudgetItemController.shared.updateBudgetWith(name: budgetItem.name , spentTotal: budgetItem.spentTotal, totalAlloted: totalAllotedAsDouble, allottedAmount: budgetItem.allottedAmount, budgetItem: budgetItem, completion: { (_) in
                self.reloadCategoryTableViewAndUI()
            })
        }
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Methods

    /// This will clear all the information in User Defaults this is used for testing...
    func clearAllDataInUserDefaults() {
                let domain = Bundle.main.bundleIdentifier!
                UserDefaults.standard.removePersistentDomain(forName: domain)
                UserDefaults.standard.synchronize()
                print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
    }
    
    func addPropertyObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCategoryTableViewAndUI), name: Notifications.budgetItemWasUpdatedNotifaction, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateNotCurrentlyBudgetedLabel), name: Notifications.projectedIncomeWasUpdatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateIncomeNotCurrentlyBudgetedTitleLabel), name: Notifications.projectedIncomeWasUpdatedNotification, object: nil)
    }
    
    /// This function adds up the total of all current monthly budget items
    func addUpTotalSpentOfBudget() -> Double {
//        let plannedExpenseMonthlyContribution = PlannedExpenseController.shared.calculateTotalMonthlyContribution()
        var totalSpentOfBudget: Double = 0.0
        for budgetItem in BudgetItemController.shared.budgetItems {
            totalSpentOfBudget += budgetItem.spentTotal
        }
        return totalSpentOfBudget
    }
    
    func calculatedNotCurrentlyBudgetedTotal() -> Double {
        guard let user = UserController.shared.user else {return 0.0}
        let totalBudget = user.projectedIncome
        let plannedExpenseMonthlyContribution = PlannedExpenseController.shared.calculateTotalMonthlyContribution()
        var total = 0.0
        let budgetItems = BudgetItemController.shared.budgetItems
        for budgetItem in budgetItems {
            if let totalAllotted = budgetItem.totalAllotted {
                total += totalAllotted
            } else {
                total += budgetItem.allottedAmount
            }
        }
        total += plannedExpenseMonthlyContribution
        return totalBudget - total
    }
    
    /// This function updates the monthly budget label
    func updateMonthlyBudgetLabel() {
        DispatchQueue.main.async {
            self.totalBudgetedIncomLabel.text = "\(formatNumberToString(fromDouble: self.addUpTotalSpentOfBudget()))"
        }
    }
    
    @objc func updateIncomeNotCurrentlyBudgetedTitleLabel() {
        
        guard let user = UserController.shared.user else { return }
        if user.projectedIncome <= 0.0 {
            incomeNotCurrentlyBudgetLabel.isHidden = true
        } else {
            incomeNotCurrentlyBudgetLabel.isHidden = false
        }
    }
    

    
    @objc func updateNotCurrentlyBudgetedLabel() {
        DispatchQueue.main.async {
            self.incomeNotCurrentlyBudgetLabel.text = "\(formatNumberToString(fromDouble: self.calculatedNotCurrentlyBudgetedTotal()))"
        }
    }
    
    @objc func reloadCategoryTableViewAndUI() {
        DispatchQueue.main.async {
            self.updateUI()
            self.updatePieChartAndLegendView()
            self.view.setNeedsDisplay()
            self.categoryTableView.reloadData()
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    // MARK: - UI
    func setUpUI() {
        configureNavigationBar()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        setUpDelegatesAndDataSources()
        createPlusButton()
    }
    
    private func updateUI() {
        // Update all labels in the view below the budget items
        updateMonthlyBudgetLabel()
        updateNotCurrentlyBudgetedLabel()
        
        // If there is a projected income assign the value
        let projectedIncome = UserController.shared.user?.projectedIncome
        guard let projected = projectedIncome else {NSLog("There is no projected Income"); return}
            
        amountTextField.text = formatNumberToString(fromDouble: projected)
        
        }
    
    
    func configureNavigationBar() {
        guard let font = UIFont(name: "Avenir Next", size: 17) else {return}
        let attributes = [ NSAttributedStringKey.font: font,
                           NSAttributedStringKey.foregroundColor : UIColor.white,
                           ]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.navigationItem.title = self.navigationItem.title
    }
    
    func setUpDelegatesAndDataSources() {
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        categoryTableView.estimatedRowHeight = 50
        categoryTableView.rowHeight = UITableViewAutomaticDimension
        amountTextField.delegate = self
        
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
        pieChartView.createLegendView(fromView: legendView)
        pieChartView.formatPieChartViewAndLegend(withPieCharView: pieChartView, andLegendView: legendView, usingFilteredDictionary: filteredDictionary, withFontSize: 12)
        pieChartView.formatInnerCircle(fromPieChartView: whiteCircle)
    }
    
    func createAndUpdateProjected(income: Double) {
        let defaults = UserDefaults.standard
        let hasLaunched = defaults.bool(forKey: hasLaunchedKey)
        
        if !hasLaunched {
            defaults.set(true, forKey: hasLaunchedKey)
            UserController.shared.createUser(withProjectedIncome: income, completion: nil)
        } else {
            guard let user = UserController.shared.user else {NSLog("There is no User"); return}
            UserController.shared.updateUserWith(projectedIncome: income, user: user, hasResetMonthBudget: user.hasResetMonthlyBudget ?? nil, completion: { (_) in })
            self.projectedIncome = income
        }
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
        
        guard let string = textField.text else { return false }
        let stringToChange = string.dropFirst()
        
        if textField.text != "$" {
            guard let income = Double(stringToChange) else {
                presentSimpleAlert(controllerToPresentAlert: self, title: "Error", message: "You entered an invalid amount!")
                return false
            }
            
            createAndUpdateProjected(income: income)
            updateMonthlyBudgetLabel()
        }
        textField.resignFirstResponder()
        return false
    }
}




















