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
    
    // MARK: - Properties
    
    // MARK: - View LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setPickerDelegates()
        setUpUI()
        
    }
    
    // MARK: - Picker Button Actions
    @IBAction func accountButtonWasPressed(_ sender: Any) {
        accountPicker.isHidden = false
        datePicker.isHidden = true
        categoryPicker.isHidden = true
    }
    
    @IBAction func dateButtonWasPressed(_ sender: Any) {
        accountPicker.isHidden = true
        datePicker.isHidden = false
        categoryPicker.isHidden = true
    }
    @IBAction func categoryButtonWasPressed(_ sender: Any) {
        accountPicker.isHidden = true
        datePicker.isHidden = true
        categoryPicker.isHidden = false
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
    
    
    func setUpUI() {
        accountPicker.isHidden = true
        categoryPicker.isHidden = true
    }
    
    func setPickerDelegates() {
        accountPicker.dataSource = self
        accountPicker.delegate = self
    }

    
    func checkWhichControlIsPressed() {
        
        if transactionType.selectedSegmentIndex == 0 {
            // This is an income
            
        } else {
            // This is an expense
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
    
    // MARK: - Save Transactions
    func saveTransaction() {
        
    }
    
    
}



















