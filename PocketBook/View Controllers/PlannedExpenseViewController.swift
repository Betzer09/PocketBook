//
//  PlannedExpenseViewController.swift
//  PocketBook
//
//  Created by Laura O'Brien on 11/6/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class PlannedExpenseViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    // MARK: - Outlets
    @IBOutlet weak var accountPicker: UIPickerView!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var inititalAmountTextField: UITextField!
    @IBOutlet weak var goalAmountTextField: UITextField!
    
    // MARK: - Properties
    var plannedExpense: PlannedExpense?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Picker View Functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return AccountController.shared.accounts.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let account = AccountController.shared.accounts[row]
        
        return account.name
        
    }
    
    
    // MARK: - Actions
    @IBAction func saveButtonPressed(_ sender: Any) {
        savePlannedExpense()
    }
    
    // MARK: - Methods
    private func savePlannedExpense() {
        
        if plannedExpense != nil {
            // Update the planned expense
            if let name = nameTextField.text,
                let inititalAmountString = inititalAmountTextField.text,
                let goalAmountString = goalAmountTextField.text,
                let plannedExpense = plannedExpense {
                
                guard let inititalAmount = Double(inititalAmountString),
                    let goalAmount = Double(goalAmountString) else {return}
                
                PlannedExpenseController.shared.updatePlannedExpenseWith(name: name, account: accountPicker.description, initialAmount: inititalAmount, goalAmount: goalAmount, totalSaved: 0, dueDate: dueDatePicker.date, plannedExpense: plannedExpense , completion: { (_) in
                    
                })
            }
        } else {
            // Save the planned Expense
            
            guard let name = nameTextField.text,
                let inititalAmountString = inititalAmountTextField.text,
                let goalAmountString = goalAmountTextField.text else { return }
                
                guard let inititalAmount = Double(inititalAmountString),
                    let goalAmount = Double(goalAmountString) else {return}
            
            PlannedExpenseController.shared.createPlannedExpenseWith(name: name, account: accountPicker.description, initialAmount: inititalAmount, goalAmount: goalAmount, dueDate: dueDatePicker.date, completion: nil)
        }
        
    }
    
    
}
