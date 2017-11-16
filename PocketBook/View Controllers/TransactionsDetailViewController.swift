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
    @IBOutlet weak var accountPicker: UIPickerView!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var transactionType: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var payeeTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    
    
    // MARK: - Properties
    var transaction: Transaction?
    var budgetItem: BudgetItem?
    var plannedExpenseTransaction: PlannedExpense?
    var currentYShiftForKeyboard: CGFloat = 0
    var textFieldBeingEdited: UITextField?
    
    // MARK: - View LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setPickerDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUIWhenTheViewLoads()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    // MARK: - Actions
    
    @IBAction func SaveButtonPressed(_ sender: UIBarButtonItem) {
        saveTransaction()
    }
    
    // MARK: - Picker Button Actions
    @IBAction func dateButtonWasPressed(_ sender: Any) {
        accountPicker.isHidden = true
        datePicker.isHidden = false
        categoryPicker.isHidden = true
    }
    
    @IBAction func accountButtonWasPressed(_ sender: Any) {
        accountPicker.isHidden = false
        categoryPicker.isHidden = true
        accountButton.isHidden = true
    }
    
    @IBAction func categoryButtonWasPressed(_ sender: Any) {
        accountPicker.isHidden = true
        categoryPicker.isHidden = false
        categoryButton.isHidden = true
    }
    
    @IBAction func dateButtonPressed(_ sender: UIButton) {
        datePicker.isHidden = false
        dateButton.isHidden = true
        categoryPicker.isHidden = true
        accountPicker.isHidden = true
    }
    
    
    // Date Picker Action
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        self.dateButton.setTitle(returnFormattedDateString(date: datePicker.date), for: .normal)
        datePicker.isHidden = true
        dateButton.isHidden = false
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch pickerView {
        case accountPicker:
            var stringArray = AccountController.shared.accounts.map { $0.name }
            accountButton.setTitle(stringArray[row], for: .normal)
            accountPicker.isHidden = true
            accountButton.isHidden = false
        case categoryPicker:
            let category = BudgetItemController.shared.budgetItems.map( { $0.name } )
            categoryButton.setTitle(category[row], for: .normal)
            categoryPicker.isHidden = true
            categoryButton.isHidden = false
        default:
            print("Error seting up picker in function: \(#function)")
        }
    }
    
    
    // MARK: - UI View Preperation
    func configureUIWhenTheViewLoads() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        payeeTextField.delegate = self
        amountTextField.delegate = self
        
        accountPicker.isHidden = true
        categoryPicker.isHidden = true
        dateButton.isHidden = true
        
        accountButton.setTitle("Choose Account", for: .normal)
        categoryButton.setTitle("Choose Category", for: .normal)
        
        // Checks to see if there is a transaction and if there is a transactions, all fields will auto-populate with the transaction data
        
        if transaction != nil {
            guard let transaction = transaction else { return }
            
            var stringAmount = String(format: "%.2f", transaction.amount)
            stringAmount.insert("$", at: stringAmount.startIndex)
            
            amountTextField.text = stringAmount
            payeeTextField.text = transaction.payee
            datePicker.date = transaction.date
            accountButton.setTitle(transaction.account, for: .normal)
            categoryButton.setTitle(transaction.category, for: .normal)
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
            
            guard let plannedExpense = plannedExpenseTransaction else { return }
            
            var stringAmount = String(format: "%.2f", plannedExpense.totalSaved!)
            stringAmount.insert("$", at: stringAmount.startIndex)
            
            amountTextField.text = stringAmount
            payeeTextField.text = plannedExpense.account
            datePicker.date = returnFormattedDate(date: plannedExpense.dueDate)
            accountButton.setTitle(plannedExpense.account, for: .normal)
            categoryButton.setTitle(plannedExpense.name, for: .normal)
            
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
    
   @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
   @objc func keyboardWillHide(notification: NSNotification) {
        
        if self.view.frame.origin.y != 0 {
            
            self.view.frame.origin.y += currentYShiftForKeyboard
        }
        
        stopEditingTextField()
    }
    
    
    // MARK: - Methods
    
    private func presentSimpleAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(dismissAction)
        
        self.present(alert, animated: true, completion: nil)
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
    
    // MARK: - Save Button Pressed
    private func saveTransaction() {
        if transaction != nil {
            
            var convertedAmount: Double?
            guard let transaction = transaction else { return }
            
            
            if let amountString = amountTextField.text?.dropFirst() {
                guard let amount = Double(amountString) else {return}
                convertedAmount = amount
                
            }
            
            // We want to update everything except the amount
            if transaction.amount == convertedAmount {
                
                let typeString: String = checkWhichControlIsPressed(segmentedControl: transactionType, type1: .all, type2: .income, type3: .expense)
                let type = convertStringToTransactionType(string: typeString)
                let account = AccountController.shared.accounts[accountPicker.selectedRow(inComponent: 0)]
                self.budgetItem = BudgetItemController.shared.budgetItems[categoryPicker.selectedRow(inComponent: 0)]
                guard let budgetItem = budgetItem else {return}
                BudgetItemController.shared.configureMonthlyBudgetExpensesForBudgetItem(transaction: transaction, transactionType: type, account: account, budgetItem: budgetItem )
                
            } else {
                // Update everything including the amount
                
                guard let convertedAmount = convertedAmount else {return}
                transaction.amount = convertedAmount - transaction.amount
                print("Difference: \(transaction.amount)")
                
                let typeString: String = checkWhichControlIsPressed(segmentedControl: transactionType, type1: .all, type2: .income, type3: .expense)
                let type = convertStringToTransactionType(string: typeString)
                let account = AccountController.shared.accounts[accountPicker.selectedRow(inComponent: 0)]
                self.budgetItem = BudgetItemController.shared.budgetItems[categoryPicker.selectedRow(inComponent: 0)]
                guard let budgetItem = budgetItem else {return}
                BudgetItemController.shared.configureMonthlyBudgetExpensesForBudgetItem(transaction: transaction, transactionType: type, account: account, budgetItem: budgetItem)
                
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
            let categoryButton = categoryButton.currentTitle,
            let accountButton = accountButton.currentTitle,
            let amount = amountTextField.text, !payee.isEmpty, !amount.isEmpty else {
                presentSimpleAlert(title: "Couldn't Save Data!", message: "Make sure all the fields have been filled")
                return
        }
        
        guard let amountToSave = Double(amount.dropFirst()) else {
            presentSimpleAlert(title: "Error", message: "Amount textfield isn't a Double")
            return
        }
        
        let typeString: String = checkWhichControlIsPressed(segmentedControl: transactionType, type1: .all, type2: .income, type3: .expense)
        let type = convertStringToTransactionType(string: typeString)
        let account = AccountController.shared.accounts[accountPicker.selectedRow(inComponent: 0)]
        budgetItem = BudgetItemController.shared.budgetItems[categoryPicker.selectedRow(inComponent: 0)]
        
        TransactionController.shared.createTransactionWith(date: returnFormattedDate(date: datePicker.date), category: categoryButton, payee: payee, transactionType: typeString, amount: amountToSave, account: accountButton, completion: { (transaction) in
            
            // FIXME: If it looks like something is weird try commenting me out and trying agian
            guard let budgetItem = self.budgetItem else {return}
            BudgetItemController.shared.configureMonthlyBudgetExpensesForBudgetItem(transaction: transaction, transactionType: type, account: account, budgetItem: budgetItem)
            
        })
    }
    
    private func updateTransaction() {
        // We want to update
        guard let transaction = transaction,
            let payee = payeeTextField.text,
            let categoryButton = categoryButton.currentTitle,
            let accountButton = accountButton.currentTitle,
            let amount = amountTextField.text else {return}
        
        guard let amountToSave = Double(amount.dropFirst()) else {
            presentSimpleAlert(title: "Error", message: "Amount textfield isn't a Double")
            return
        }
        let typeString: String = checkWhichControlIsPressed(segmentedControl: transactionType, type1: .all, type2: .income, type3: .expense)
        
        TransactionController.shared.updateTransactionWith(transaction: transaction, date: returnFormattedDate(date: datePicker.date), category: categoryButton, payee: payee, transactionType: typeString, amount: amountToSave, account: accountButton, completion: { (_) in
        })
    }
}


