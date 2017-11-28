//
//  TransactionsDetailViewController.swift
//  PocketBook
//
//  Created by Laura O'Brien on 11/6/17.
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
        if let transaction = transaction {
            self.navigationItem.title = "Transaction Details"
        } else {
            self.navigationItem.title = "Create New Transaction"
        }
        setPickerDelegates()
        customizeSegmentedControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUIWhenTheViewLoads()
        customizeSegmentedControl()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    // MARK: - Actions
    
    @IBAction func SaveButtonPressed(_ sender: UIBarButtonItem) {
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
    
    // MARK: - UI View Preperation
    func configureUIWhenTheViewLoads() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        payeeTextField.delegate = self
        amountTextField.delegate = self
        
        showCategoryPicker()
        showDatePicker()
        showAccountPicker()
        
        // Checks to see if there is a transaction and if there is a transactions, all fields will auto-populate with the transaction date
        if transaction != nil {
            guard let transaction = transaction else { return }
            
            let stringAmount = formatNumberToString(fromDouble: transaction.amount)
            
            amountTextField.text = stringAmount
            payeeTextField.text = transaction.payee
            dateTextField.text =  returnString(fromDate: transaction.date)
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
        
        if plannedExpenseTransaction != nil {
            
            transactionType.isHidden = true
            
            guard let plannedExpense = plannedExpenseTransaction,
                    let plannedExpenseDouble = plannedExpense.totalSaved else { return }
            
            let stringAmount = formatNumberToString(fromDouble: plannedExpenseDouble)
            
            amountTextField.text = stringAmount
            payeeTextField.text = plannedExpense.name
            dateTextField.text = returnString(fromDate: plannedExpense.dueDate)
            
            let budgetItems = BudgetItemController.shared.budgetItems
            guard let selectedBugetItem = budgetItems.index(where: { $0.name == plannedExpense.account }) else {return}
            categoryPicker.selectRow(selectedBugetItem, inComponent: 0, animated: true)
            
            let accounts = AccountController.shared.accounts
            guard let selectedAccount = accounts.index(where: { $0.name == plannedExpense.name }) else {return}
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
     
        toolbar.setItems([doneButton, spaceButton, cancelButton], animated: false)
        categoryTextField.inputAccessoryView = toolbar
        categoryTextField.inputView = categoryPicker
        

    }
    
    @objc func doneCategoryPicker() {
        let category = BudgetItemController.shared.budgetItems[categoryPicker.selectedRow(inComponent: 0)]
        categoryTextField.text = category.name
        self.view.endEditing(true)
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
        
        toolbar.setItems([doneButton, spaceButton, cancelButton], animated: false)
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
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        accountTextField.inputAccessoryView = toolbar
        accountTextField.inputView = accountPicker
    }
    
    @objc func doneAccountPicker() {
        
        let account = AccountController.shared.accounts[accountPicker.selectedRow(inComponent: 0)]
        accountTextField.text = account.name
        self.view.endEditing(true)
    }
    
    
    @objc func doneDatePicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        dateTextField.text = formatter.string(from: dueDatePicker.date)
        self.view.endEditing(true)
    }
    
    // MARK: - Save Button Pressede
    private func saveTransaction() {
        if transaction != nil {
            
            var convertedAmount: Double?
            var difference: Double?
            guard let transaction = transaction else { return }
            
            
            if let amountString = amountTextField.text?.dropFirst() {
                guard let amount = Double(amountString) else {return}
                convertedAmount = amount
                
            }
            
            // Since the amounts are the same we want to update everything except the amount
            if transaction.amount == convertedAmount {
                
                let typeString: String = checkWhichControlIsPressed(segmentedControl: transactionType, type1: .all, type2: .income, type3: .expense)
                let type = convertStringToTransactionType(string: typeString)
                let account = AccountController.shared.accounts[accountPicker.selectedRow(inComponent: 0)]
                self.budgetItem = BudgetItemController.shared.budgetItems[categoryPicker.selectedRow(inComponent: 0)]
                guard let budgetItem = budgetItem else {return}
                BudgetItemController.shared.configureMonthlyBudgetExpensesForBudgetItem(transaction: transaction, transactionType: type, account: account, budgetItem: budgetItem)
                
            } else {
                // Update everything including the amount
                let typeString: String = checkWhichControlIsPressed(segmentedControl: transactionType, type1: .all, type2: .income, type3: .expense)
                let type = convertStringToTransactionType(string: typeString)
                let account = AccountController.shared.accounts[accountPicker.selectedRow(inComponent: 0)]
                
                // This means the transaction Type is changing and we want to keep the full total
                if transaction.transactionType != typeString {
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
                    
                    self.budgetItem = BudgetItemController.shared.budgetItems[categoryPicker.selectedRow(inComponent: 0)]
                    guard let budgetItem = budgetItem else {return}
                    difference = convertedAmount - transaction.amount
                    guard let difference = difference else {return}
                    print("Difference: \(difference)")
                    BudgetItemController.shared.configureMonthlyBudgetExpensesForBudgetItem(transaction: transaction, transactionType: type, account: account, budgetItem: budgetItem, difference: difference)

                }
            }
            
            updateTransaction()
            
        } else {
            createTransaction()
        }
        navigationController?.popViewController(animated: true)
    }
    
    private func createTransaction() {
        // We want to create
        guard let payee = payeeTextField.text,
            let categoryName = categoryTextField.text,
            let accountName = accountTextField.text,
            let amount = amountTextField.text, !payee.isEmpty, !amount.isEmpty else {
                presentSimpleAlert(controllerToPresentAlert: self, title: "Couldn't Save Data!", message: "Make sure all the fields have been filled")
                return
        }
        
        guard let amountToSave = Double(amount.dropFirst()) else {
            presentSimpleAlert(controllerToPresentAlert: self, title: "Error", message: "Please re-enter amount using numbers")
            return
        }
        
        if categoryButton == "Choose Category" && accountButton == "Choose Account" {
            presentSimpleAlert(controllerToPresentAlert: self, title: "Error", message: "Please select a category and an account. If you haven't created categories or accounts yet, you must create both before you can start creating transactions")
                return
        } else if categoryButton == "Choose Category" {
            presentSimpleAlert(controllerToPresentAlert: self, title: "Error", message: "Please select a category. If you haven't created categories yet, please create at least one category before creating a transaction")
                return
        } else if accountButton == "Choose Account" {
            presentSimpleAlert(controllerToPresentAlert: self, title: "Error", message: "Please select an account. If you haven't created an account yet, you must create at least one account before you can create transactions")
                return
        }
       
        
        let typeString: String = checkWhichControlIsPressed(segmentedControl: transactionType, type1: .all, type2: .income, type3: .expense)
        let type = convertStringToTransactionType(string: typeString)
        let account = AccountController.shared.accounts[accountPicker.selectedRow(inComponent: 0)]
        budgetItem = BudgetItemController.shared.budgetItems[categoryPicker.selectedRow(inComponent: 0)]
        
        TransactionController.shared.createTransactionWith(date: dueDatePicker.date, monthYearDate: returnFormattedDate(date: dueDatePicker.date), category: categoryName, payee: payee, transactionType: typeString, amount: amountToSave, account: accountName, completion: { (transaction) in
            
            // FIXME: If it looks like something is weird try commenting me out and trying agian
            guard let budgetItem = self.budgetItem else {return}
            BudgetItemController.shared.configureMonthlyBudgetExpensesForBudgetItem(transaction: transaction, transactionType: type, account: account, budgetItem: budgetItem)
            
        })
    }
    
    private func updateTransaction() {
        // We want to update
        guard let transaction = transaction,
            let payee = payeeTextField.text,
            let categoryButton = categoryTextField.text,
            let accountButton = accountTextField.text,
            let amount = amountTextField.text else {return}
        
        guard let amountToSave = Double(amount.dropFirst()) else {
            presentSimpleAlert(controllerToPresentAlert: self, title: "Error", message: "Amount textfield isn't a Double")
            return
        }
        let typeString: String = checkWhichControlIsPressed(segmentedControl: transactionType, type1: .all, type2: .income, type3: .expense)
        
        TransactionController.shared.updateTransactionWith(transaction: transaction, date: dueDatePicker.date, monthYearDate: returnFormattedDate(date: dueDatePicker.date),category: categoryButton, payee: payee, transactionType: typeString, amount: amountToSave, account: accountButton, completion: { (_) in
        })
    }
}


