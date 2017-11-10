//
//  TransactionsDetailViewController.swift
//  PocketBook
//
//  Created by Laura O'Brien on 11/6/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class TransactionsDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
    
    // MARK: - View LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setPickerDelegates()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUI()
    }
    
    // MARK: - Actions
    
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
    
    // This function returns a date as a date in the format "dd-MM-yyyy"
    func returnFormattedDate() -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let strDate = dateFormatter.string(from: datePicker.date)
        let date: Date? = dateFormatter.date(from: strDate)
        return date ?? Date()
        
    }
    
    // This function return a date as a String in the format "dd-MM-yyyy"
    func returnFormattedDateString() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let strDate = dateFormatter.string(from: datePicker.date)
        return strDate
        
    }
    
    // Date Picker Action
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        self.dateButton.setTitle(returnFormattedDateString(), for: .normal)
        datePicker.isHidden = true
        dateButton.isHidden = false
    }
    
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
            let category = combinedCategoryNames()
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
            let category = combinedCategoryNames()
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
            let category = combinedCategoryNames()
            categoryButton.setTitle(category[row], for: .normal)
            categoryPicker.isHidden = true
            categoryButton.isHidden = false
        default:
            print("Error seting up picker in function: \(#function)")
        }
    }
    
    
    func setUpUI() {
        
        accountPicker.isHidden = true
        categoryPicker.isHidden = true
        dateButton.isHidden = true
        
        accountButton.setTitle("Choose Account", for: .normal)
        categoryButton.setTitle("Choose Category", for: .normal)
        
        // Checks to see if there is a transaction and if there is a transactions, all fields will auto-populate with the transaction data
        
        if transaction != nil {
            guard let transaction = transaction else { return }
            
            amountTextField.text = "\(transaction.amount)"
            payeeTextField.text = transaction.payee
            datePicker.date = transaction.date
            accountButton.setTitle(transaction.account, for: .normal)
            categoryButton.setTitle(transaction.catagory, for: .normal)
        }
    }
    
    func setPickerDelegates() {
        
        accountPicker.dataSource = self
        categoryPicker.dataSource = self
        
        accountPicker.delegate = self
        categoryPicker.delegate = self
        
    }
    
    
    func checkWhichControlIsPressed() -> String {
        
        if transactionType.selectedSegmentIndex == 0 {
            print("Income selected segment")
            return "Income"
            
        } else {
            print("Expenses selected segment")
            return "Expense"
        }
    }
    
    func combinedCategoryNames() -> [String] {
        
        // Go though each budgetItem and grab the name
        let budgetItemNames = AccountController.shared.accounts.map({ $0.name })
        
        let plannedExpenseNames = PlannedExpenseController.shared.plannedExpenses.map({ $0.name })
        
        // A category is a combination between planned expense and budget Items
        let category = plannedExpenseNames + budgetItemNames
        return category
    }
    
    // MARK: - Save Button Pressed
    
    
    
    func saveTransaction() {
        
        if transaction != nil {
            // We want to update
            guard let transaction = transaction,
                let payee = payeeTextField.text,
                let categoryButton = categoryButton.currentTitle,
                let accountButton = accountButton.currentTitle,
                let amount = amountTextField.text else {return}
            
            TransactionController.shared.updateTransactionWith(transaction: transaction, date: returnFormattedDate(), category: categoryButton, payee: payee, transactionType: checkWhichControlIsPressed(), amount: Double(amount)!, account: accountButton, completion: { (_) in
            })
            
        } else {
            // We want to create
            guard let payee = payeeTextField.text,
                let categoryButton = categoryButton.currentTitle,
                let accountButton = accountButton.currentTitle,
                let amount = amountTextField.text else {return}
            
            TransactionController.shared.createTransactionWith(date: returnFormattedDate(), category: categoryButton, payee: payee, transactionType: checkWhichControlIsPressed(), amount: Double(amount)!, account: accountButton, completion: nil )
        }
        navigationController?.popViewController(animated: true)
    }
}

















