//
//  TransactionsDetailViewController.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/7/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class TransactionsDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
 
    // MARK: - Outlets

    @IBOutlet weak var transactionType: UISegmentedControl!
    @IBOutlet weak var payeeTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var payeeLabel: UILabel!
    
    // MARK: - Customize Segmented Control
    func customizeSegmentedControl() {
        transactionType.customizeSegmentedControl()
    }
    
    // MARK: - Properties
    var transaction: Transaction?
    var budgetItem: BudgetItem?
    var plannedExpenseTransaction: PlannedExpense?
    var currentYShiftForKeyboard: CGFloat = 0
    var textFieldBeingEdited: UITextField?
    
    let dueDatePicker = UIDatePicker()
    let accountPicker = UIPickerView()
    let categoryPicker = UIPickerView()
    
    // MARK: - View LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
       setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUIWhenTheViewLoads()
        customizeSegmentedControl()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    // MARK: - Setup UI
    func setUpUI() {
        configureNavigationController()
        setPickerDelegates()
        customizeSegmentedControl()
        customizePayeeLabel()
        setUpDatePicker()
    }
    
    func setUpDatePicker() {
        dueDatePicker.maximumDate = Date()
    }
    
    func configureNavigationController() {
        self.navigationController?.navigationBar.tintColor = .white
        if transaction != nil {
            self.navigationItem.title = "Transaction Details"
        } else {
            self.navigationItem.title = "Create New Transaction"
        }
    }
    
    // MARK: - Actions
    
    @IBAction func segmentedControlPressed(_ sender: Any) {
        customizePayeeLabel()
    }
    
    @IBAction func SaveButtonPressed(_ sender: UIBarButtonItem) {
        
        guard let navController = parent as? UINavigationController,
            let tabBarController = navController.parent as? UITabBarController else { return }
        tabBarController.selectedIndex = 2
        
        saveTransaction()

    }
    
    // MARK: - Account Picker Delegates
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView {
        case accountPicker:
            return AccountController.shared.accounts.count
        case categoryPicker:
            let category = BudgetItemController.shared.budgetItems
            return category.count
            
        default:
            print("There was a problem displaying information for the picker: \(#file)")
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView {
        case accountPicker:
            let account = AccountController.shared.accounts[row]
            return account.name
        case categoryPicker:
            // Category is a combination between planned expense and budgetItem names
            let category = BudgetItemController.shared.budgetItems.map( { $0.name } )
            return category[row]
            
        default:
            print("There was a problem displaying information for the picker: \(#file)")
            return "oops"
        }
        
    }
    
    // MARK: - UI Preperation
    func configureUIWhenTheViewLoads() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        payeeTextField.delegate = self
        amountTextField.delegate = self
        
        showCategoryPicker()
        showDatePicker()
        showAccountPicker()
        
        // Checks to see if the transaction is a Planned Expense
        guard let transactionTypeToCheck = transaction?.transactionType else {
            
            if plannedExpenseTransaction != nil {
                
                transactionType.isHidden = true
                categoryTextField.isHidden = true
                categoryLabel.isHidden = true
                
                if transaction != nil {
                    guard let transaction = transaction else {return}
                    amountTextField.text = formatNumberToString(fromDouble: transaction.amount)
                    payeeTextField.text = transaction.payee.lowercased().capitalized
                    dateTextField.text = returnFormattedDateAsString(date: transaction.date)
                    accountTextField.text = transaction.account
                }
                
                guard let plannedExpense = plannedExpenseTransaction else { return }
                    let plannedExpenseDouble = plannedExpense.totalDeposited + plannedExpense.initialAmount
                
                let stringAmount = formatNumberToString(fromDouble: plannedExpenseDouble)
                
                
                amountTextField.text = stringAmount
                payeeTextField.text = plannedExpense.name.lowercased().capitalized
                dateTextField.text = returnFormattedDateAsString(date: plannedExpense.dueDate)
                accountTextField.text = plannedExpense.account
                
                let budgetItems = BudgetItemController.shared.budgetItems
                guard let selectedBugetItem = budgetItems.index(where: { $0.name == plannedExpense.account }) else {return}
                categoryPicker.selectRow(selectedBugetItem, inComponent: 0, animated: true)
                
                let accounts = AccountController.shared.accounts
                guard let selectedAccount = accounts.index(where: { $0.name == plannedExpense.name }) else {return}
                accountPicker.selectRow(selectedAccount, inComponent: 0, animated: true)
                
            }
            return
        }
        
        if transactionTypeToCheck == TransactionType.plannedExpense.rawValue {
            transactionType.isHidden = true
            categoryTextField.isHidden = true
            categoryLabel.isHidden = true
            
            if transaction != nil {
                guard let transaction = transaction else {return}
                amountTextField.text = formatNumberToString(fromDouble: transaction.amount)
                payeeTextField.text = transaction.payee.lowercased().capitalized
                dateTextField.text = returnFormattedDateAsString(date: transaction.date)
                accountTextField.text = transaction.account
            }
            
            guard let plannedExpense = plannedExpenseTransaction else { return }
            
            let plannedExpenseDouble = plannedExpense.totalDeposited
            let stringAmount = formatNumberToString(fromDouble: plannedExpenseDouble)
            
            
            amountTextField.text = stringAmount
            payeeTextField.text = plannedExpense.name.lowercased().capitalized
            dateTextField.text = returnFormattedDateAsString(date: plannedExpense.dueDate)
            accountTextField.text = plannedExpense.account

        }
        
        // Checks to see if there is a transaction and if there is a transactions, all fields will auto-populate with the transaction date
        if transaction != nil {
            guard let transaction = transaction else { return }
            
            let stringAmount = formatNumberToString(fromDouble: transaction.amount)
            
            amountTextField.text = stringAmount
            payeeTextField.text = transaction.payee.lowercased().capitalized
            dateTextField.text =  returnFormattedDateAsString(date: transaction.date)
            accountTextField.text = transaction.account
            categoryTextField.text = transaction.category
            transactionType.selectedSegmentIndex = updateTransactionType()
            
            let budgetItems = BudgetItemController.shared.budgetItems
            guard let selectedBugetItem = budgetItems.index(where: { $0.name == transaction.category }) else {return}
            categoryPicker.selectRow(selectedBugetItem, inComponent: 0, animated: true)
            
            let accounts = AccountController.shared.accounts
            guard let selectedAccount = accounts.index(where: { $0.name == transaction.account }) else {return}
            accountPicker.selectRow(selectedAccount, inComponent: 0, animated: true)
            
        }
    }
    
    func setPickerDelegates() {
        
        accountPicker.dataSource = self
        categoryPicker.dataSource = self
        
        accountPicker.delegate = self
        categoryPicker.delegate = self
        
    }
    
    // MARK: - Text Field Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == amountTextField {
            amountTextField.text = "$"
        }
        textFieldBeingEdited = textField
    }
    
    
    // MARK: - Keyboard Functions
    func yShiftWhenKeyboardAppearsFor(textField: UITextField, keyboardHeight: CGFloat, nextY: CGFloat) -> CGFloat {
        
        let textFieldOrigin = self.view.convert(textField.frame, from: textField.superview!).origin.y
        let textFieldBottomY = textFieldOrigin + textField.frame.size.height
        
        // This is the y point that the textField's bottom can be at before it gets covered by the keyboard
        let maximumY = self.view.frame.height - keyboardHeight
        
        if textFieldBottomY > maximumY {
            // This makes the view shift the right amount to have the text field being edited 60 points above they keyboard if it would have been covered by the keyboard.
            return textFieldBottomY - maximumY + 60
        } else {
            // It would go off the screen if moved, and it won't be obscured by the keyboard.
            return 0
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        var keyboardSize: CGRect = .zero
        
        if let keyboardRect = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect,
            keyboardRect.height != 0 {
            keyboardSize = keyboardRect
        } else if let keyboardRect = notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as? CGRect {
            keyboardSize = keyboardRect
        }
        
        if let textField = textFieldBeingEdited {
            if self.view.frame.origin.y == 0 {
                
                let yShift = yShiftWhenKeyboardAppearsFor(textField: textField, keyboardHeight: keyboardSize.height, nextY: keyboardSize.height)
                self.currentYShiftForKeyboard = yShift
                self.view.frame.origin.y -= yShift
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        if self.view.frame.origin.y != 0 {
            
            self.view.frame.origin.y += currentYShiftForKeyboard
        }
        
        stopEditingTextField()
    }
    
   @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    // MARK: - Methods
    
    /// Takes in a date and returns a string formated Jan 7, 2019
    func returnFormattedDateAsString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let string = dateFormatter.string(from: date)
        return string

    }
    
    func customizePayeeLabel() {
        if transactionType.selectedSegmentIndex == 0 {
            payeeLabel.text = "Vendor"
        } else {
            payeeLabel.text = "Payer"
        }
    }
    
    ///Checks to see which segment should be highlighted
    private func updateTransactionType() -> Int {
        
        if transaction?.transactionType == "Income" {
            return 1
        } else {
            return 0
        }
        
    }
    
    func stopEditingTextField() {
        view.endEditing(true)
    }
    
    
    // MARK: - ToolBar Picker Views
    
    func showCategoryPicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneCategoryPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissKeyboard))
     
        toolbar.setItems([cancelButton, spaceButton,doneButton], animated: false)
        categoryTextField.inputAccessoryView = toolbar
        categoryTextField.inputView = categoryPicker
        

    }

    func showDatePicker() {
        if transaction == nil {
            dueDatePicker.date = Date()
        }
        
        // ToolBar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // Done and Cancel Button
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissKeyboard))
        
        dueDatePicker.datePickerMode = .date
        
        toolbar.setItems([cancelButton, spaceButton,doneButton], animated: false)
        dateTextField.inputAccessoryView = toolbar
        dateTextField.inputView = dueDatePicker
    }
    
    func showAccountPicker(){
        // ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        // done button & cancel button
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(doneAccountPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([cancelButton, spaceButton,doneButton], animated: false)
        accountTextField.inputAccessoryView = toolbar
        accountTextField.inputView = accountPicker
    }
    
    @objc func doneCategoryPicker() {
        let count = BudgetItemController.shared.budgetItems.count
        
        if count < 1 {
            presentSimpleAlert(controllerToPresentAlert: self, title: "Warning", message: "You need to create Monthly Budget Categories before you can start spending your money")
            return
        }
        
        let category = BudgetItemController.shared.budgetItems[categoryPicker.selectedRow(inComponent: 0)]
        categoryTextField.text = category.name
        self.view.endEditing(true)
    }
    
    @objc func doneAccountPicker() {
        let count = AccountController.shared.accounts.count
        
        if count < 1 {
            presentSimpleAlert(controllerToPresentAlert: self, title: "Warning", message: "You need to add a Checking or Savings account before you can spend money")
            return
        }
        
        let account = AccountController.shared.accounts[accountPicker.selectedRow(inComponent: 0)]
        accountTextField.text = account.name
        self.view.endEditing(true)
    }
    
    
    @objc func doneDatePicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        dateTextField.text = formatter.string(from: dueDatePicker.date)
        self.view.endEditing(true)
    }
    
    // MARK: - Save Button Pressed
    private func saveTransaction() {
        
        if transaction != nil {
            
            var convertedAmount: Double?
            var difference: Double?
            guard let transaction = transaction else { return }
            
            let amountString = removeCharactersFromTextField(amountTextField)
            guard let amount = Double(amountString) else {
                presentSimpleAlert(controllerToPresentAlert: self, title: "Error", message: "\(#function)")
                return
            }
            convertedAmount = amount
            
            // Since the amounts are the same we want to update everything except the amount
            if transaction.amount == convertedAmount {
                var type: TransactionType
                let typeString: String = checkWhichControlIsPressed(segmentedControl: transactionType, type1: .all, type2: .income, type3: .expense)
                
                if plannedExpenseTransaction != nil || transaction.transactionType == TransactionType.plannedExpense.rawValue {
                    type = .plannedExpense
                } else {
                    type = convertStringToTransactionType(string: typeString)
                    self.budgetItem = BudgetItemController.shared.budgetItems[categoryPicker.selectedRow(inComponent: 0)]
                }
                
                let account = AccountController.shared.accounts[accountPicker.selectedRow(inComponent: 0)]

                BudgetItemController.shared.configureMonthlyBudgetExpensesForBudgetItem(transaction: transaction, transactionType: type, account: account, budgetItem: self.budgetItem)
                
            } else {
                // Update everything including the amount  
                var type: TransactionType
                let typeString: String = checkWhichControlIsPressed(segmentedControl: transactionType, type1: .all, type2: .income, type3: .expense)
                
                if plannedExpenseTransaction != nil || transaction.transactionType == TransactionType.plannedExpense.rawValue {
                    type = .plannedExpense
                } else {
                    type = convertStringToTransactionType(string: typeString)
                }
                let account = AccountController.shared.accounts[accountPicker.selectedRow(inComponent: 0)]
                
                // This means the transaction Type is changing and we want to keep the full total
                if transaction.transactionType != type.rawValue {
                    // We don't want the transaciton amount to be changed
                    guard let convertedAmount = convertedAmount else {return}
                    difference = convertedAmount - transaction.amount
                    guard let difference = difference else {return}
                    transaction.amount += difference
                    
                    self.budgetItem = BudgetItemController.shared.budgetItems[categoryPicker.selectedRow(inComponent: 0)]
                    guard let budgetItem = budgetItem else {return}
                    BudgetItemController.shared.configureMonthlyBudgetExpensesForBudgetItem(transaction: transaction, transactionType: type, account: account, budgetItem: budgetItem, difference: difference)

                } else {
                    // Update everything including the amount
                    guard let convertedAmount = convertedAmount else {return}
                    transaction.amount = convertedAmount - transaction.amount
                    
                    if plannedExpenseTransaction == nil {
                    self.budgetItem = BudgetItemController.shared.budgetItems[categoryPicker.selectedRow(inComponent: 0)]
                    }
                    guard let budgetItem = budgetItem else {return}
                    difference = transaction.amount
                    guard let difference = difference else {return}
                    print("Difference: \(difference)")
                    BudgetItemController.shared.configureMonthlyBudgetExpensesForBudgetItem(transaction: transaction, transactionType: type, account: account, budgetItem: budgetItem, difference: difference)

                }
            }
            updateTransaction()
            
        } else {
            createTransaction()
        }
        if plannedExpenseTransaction != nil {
        performSegue(withIdentifier: "unwindToPlannedExpenseVC", sender: self)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func createTransaction() {
        
        var categoryNameToReturn: String = ""
        var accountNameToReturn: String
        var payeeToReturn: String
        
        if plannedExpenseTransaction == nil {
            // We want to create a normal transaction
            guard let payee = payeeTextField.text,
                let categoryName = categoryTextField.text,
                let accountName = accountTextField.text,
                !payee.isEmpty,
                !accountName.isEmpty,
                !categoryName.isEmpty else {
                    presentSimpleAlert(controllerToPresentAlert: self, title: "Couldn't Save Data!", message: "Make sure all the fields have been filled")
                    return
            }
            
            categoryNameToReturn = categoryName
            payeeToReturn = payee
            accountNameToReturn = accountName
            
        } else {
            // We want to create a planned Expense transaction
            guard let payee = payeeTextField.text,
                let accountName = accountTextField.text,
                !payee.isEmpty, !accountName.isEmpty else {
                    presentSimpleAlert(controllerToPresentAlert: self, title: "Couldn't Save Data!", message: "Make sure all the fields have been filled")
                    return
            }
            payeeToReturn = payee
            accountNameToReturn = accountName
        }
        
        let amount = removeCharactersFromTextField(amountTextField)
        
        guard let amountToSave = Double(amount) else {
            presentSimpleAlert(controllerToPresentAlert: self, title: "Error", message: "Please re-enter amount using numbers")
            return
        }

        
        if categoryTextField.text == "Choose Category" && accountTextField.text == "Choose Account" {
            presentSimpleAlert(controllerToPresentAlert: self, title: "Error", message: "Please select a category and an account. If you haven't created categories or accounts yet, you must create both before you can start creating transactions")
                return
        } else if categoryTextField.text == "Choose Category" {
            presentSimpleAlert(controllerToPresentAlert: self, title: "Error", message: "Please select a category. If you haven't created categories yet, please create at least one category before creating a transaction")
                return
        } else if accountTextField.text == "Choose Account" {
            presentSimpleAlert(controllerToPresentAlert: self, title: "Error", message: "Please select an account. If you haven't created an account yet, you must create at least one account before you can create transactions")
                return
        }
       
        
        let typeString: String = checkWhichControlIsPressed(segmentedControl: transactionType, type1: .all, type2: .income, type3: .expense)
        var type = convertStringToTransactionType(string: typeString)
        let account = AccountController.shared.accounts[accountPicker.selectedRow(inComponent: 0)]
        
        
        if plannedExpenseTransaction == nil {
            budgetItem = BudgetItemController.shared.budgetItems[categoryPicker.selectedRow(inComponent: 0)]
        } else {
            type = .plannedExpense
        }
        
        TransactionController.shared.createTransactionWith(date: dueDatePicker.date, monthYearDate: returnFormattedDate(date: dueDatePicker.date), category: categoryNameToReturn , payee: payeeToReturn, transactionType: typeString, amount: amountToSave, account: accountNameToReturn, completion: { (transaction) in
            
            // This creates a planned Expense Transaction
            if self.plannedExpenseTransaction != nil {
                // Set the type of transaction
                transaction.transactionType = TransactionType.plannedExpense.rawValue
                // Updates the transactions type
                TransactionController.shared.updateTransactionWith(transaction: transaction, date: transaction.date, monthYearDate: transaction.monthYearDate, category: transaction.category, payee: transaction.payee, transactionType: transaction.transactionType, amount: transaction.amount, account: transaction.account, completion: { (_) in })
                // Now we want to remove the planned Expense and keep it as a normal planned expense transaction instead of a planned expense
                guard let plannedExpense = self.plannedExpenseTransaction else {return}
                PlannedExpenseController.shared.delete(plannedExpense: plannedExpense)
                
                // Now we need to remove it from the array of planned expenses
                guard let plannedExpenseIndex = PlannedExpenseController.shared.plannedExpenses.index(of: plannedExpense) else {NSLog("Coudn't find Planned Expense to remove") ;return}
                PlannedExpenseController.shared.plannedExpenses.remove(at: plannedExpenseIndex)
            }
            // This will create a normal transaction
            BudgetItemController.shared.configureMonthlyBudgetExpensesForBudgetItem(transaction: transaction, transactionType: type, account: account, budgetItem: self.budgetItem, difference: transaction.amount)
        })
        
    }
    
    private func updateTransaction() {
        
        var typeString: String = checkWhichControlIsPressed(segmentedControl: transactionType, type1: .all, type2: .income, type3: .expense)
        
        
        // We want to update
        guard let transaction = transaction,
            let payee = payeeTextField.text,
            var categoryName = categoryTextField.text,
            let accountName = accountTextField.text,
            !payee.isEmpty,
            !categoryName.isEmpty,
            !accountName.isEmpty else {return}
        
        let amountToSave = removeCharactersFromTextField(amountTextField)
        guard let amount = Double(amountToSave) else {
            presentSimpleAlert(controllerToPresentAlert: self, title: "Warning", message: "The amount you entered is invalid")
            amountTextField.backgroundColor = UIColor.lightPink
            return
            
        }
        
        if transaction.transactionType == TransactionType.plannedExpense.rawValue {
            categoryName = TransactionType.plannedExpense.rawValue
            typeString = TransactionType.plannedExpense.rawValue
        }
        
        TransactionController.shared.updateTransactionWith(transaction: transaction, date: dueDatePicker.date, monthYearDate: returnFormattedDate(date: dueDatePicker.date),category: categoryName, payee: payee, transactionType: typeString, amount: amount, account: accountName, completion: { (_) in
        })
    }
}


