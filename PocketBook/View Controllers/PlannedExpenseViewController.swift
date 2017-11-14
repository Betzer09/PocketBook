//
//  PlannedExpenseViewController.swift
//  PocketBook
//
//  Created by Laura O'Brien on 11/6/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

/*STILL NEED:
 completion?!

 initialAmount is saved as an int for calculations, but comes up as a string
 
 1. TotalSaved > Progress Bar
 
 need totalSaved on update function? Do we even need an update function in the DVC?
 
 totalSaved = plannedExpense.initialAmount + (add button amount)
 

 2. Deposit button
 >Alert w/ "+"
 >segues immediately back to TVC where you can see the progress bar has been updated
 
 3. Withdraw button
 >Alert w/ "-"
 >segues immediately back to TVC where you can see the progress bar has been updated
 
 4. Complete button
 >Creates a transaction, segues to DVC
 
 5. Ideal Monthly Contribution calculations
 TO ADD TO MODEL
 var dueDate: Date? {
 guard let currentDate = DateHelper.currentDate else { return nil }
 Need to set dueDate as date selected on dueDateDatePicker
 use currentDate to calculate idealMonthlyContributionAmount
 
 */

class PlannedExpenseViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var depositButton: UIButton!
    @IBOutlet weak var withdrawButton: UIButton!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var accountPickerView: UIPickerView!
    @IBOutlet weak var accountPickerButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var initialAmountTextField: UITextField!
    @IBOutlet weak var goalAmountTextField: UITextField!
    @IBOutlet weak var dueDateDatePicker: UIDatePicker!
    @IBOutlet weak var datePickerButton: UIButton!
    @IBOutlet weak var idealMonthlyContributionAmountLabel: UILabel!
    
    //MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setPickerDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUI()
    }
    
    //MARK: - Properties
    var plannedExpense: PlannedExpense? {
        didSet {
            if isViewLoaded { updateViews() }
        }
    }
    
    let calendar = Calendar.autoupdatingCurrent
    let idealMonthlyContributionAmount = amountDifference(goalAmount: plannedExpense.goalAmount, initialAmount: plannedExpense.initialAmount) / calculatedMonthsToDueDate(dueDate: plannedExpense.dueDate, currentDate: DateHelper.currentDate)
    
    //MARK: - Functions
    private func updateViews() {
        guard let plannedExpense = plannedExpense else { return }
        nameTextField.text = plannedExpense.name
        initialAmountTextField.text = "\(plannedExpense.initialAmount)"
        goalAmountTextField.text = "\(plannedExpense.goalAmount)"
        dueDateDatePicker.date = plannedExpense.dueDate //hook up
        idealMonthlyContributionAmountLabel.text = "\(idealMonthlyContributionAmount)"
        //totalSaved calculations
    }
    
    func calculatedMonthsToDueDate(dueDate: Date, currentDate: Date) -> Int? {
        let dueDateComponents = calendar.dateComponents([.year, .month], from: dueDate)
        let currentDateComponents = calendar.dateComponents([.year, .month], from: currentDate)
        guard let dueDateYear = dueDateComponents.year,
            let dueDateMonth = dueDateComponents.month,
            let currentMonth = currentDateComponents.month,
            let currentYear = currentDateComponents.year else {return nil}
        let yearRemainder = dueDateYear - currentYear
        let monthRemainder = (12 - currentMonth) + dueDateMonth
        let total = (yearRemainder * 12) + monthRemainder
        return total
    }
    
    func amountDifference(goalAmount: Int, initialAmount: Int) -> Int? {
        let difference = goalAmount - initialAmount
        return difference
    }
    
    //MARK: - Actions
    @IBAction func depositButtonTapped(_ sender: Any) {
    }
    
    @IBAction func withdrawButtonTapped(_ sender: Any) {
    }
    
    @IBAction func completeButtonTapped(_ sender: Any) {
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if plannedExpense == nil {
            guard let plannedExpense = plannedExpense,
                let account = accountPickerButton.currentTitle,
                let name = nameTextField.text,
                let initialAmount = Double(initialAmountTextField.text!),
                let goalAmount = Double(goalAmountTextField.text!),
                let dueDate = datePickerButton.currentTitle, //needs editing
                let idealMonthlyContributionAmount = idealMonthlyContributionAmountLabel.text
                else { return }
            
            PlannedExpenseController.shared.createPlannedExpenseWith(name: name, account: account, initialAmount: initialAmount, goalAmount: goalAmount, dueDate: dueDate, completion: <#T##((PlannedExpense) -> Void)?##((PlannedExpense) -> Void)?##(PlannedExpense) -> Void#>)
            
        } else {
            
            guard let plannedExpense = plannedExpense,
                let account = accountPickerButton.currentTitle,
                let name = nameTextField.text,
                let initialAmount = initialAmountTextField.text,
                let goalAmount = goalAmountTextField.text,
                let dueDate = datePickerButton.currentTitle, //needs editing
                let idealMonthlyContributionAmount = idealMonthlyContributionAmountLabel.text
                else { return }
            
            PlannedExpenseController.shared.updatePlannedExpenseWith(name: name, account: account, initialAmount: initialAmount, goalAmount: goalAmount, totalSaved: totalSaved, dueDate: dueDate, plannedExpense: plannedExpense, completion: <#T##(PlannedExpense?) -> Void#>)
        }
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Picker Button Actions
    @IBAction func accountPickerButtonTapped(_ sender: Any) {
        accountPickerView.isHidden = false
        accountPickerButton.isHidden = true
        dueDateDatePicker.isHidden = true
    }
    
    @IBAction func datePickerButtonTapped(_ sender: Any) {
        accountPickerView.isHidden = true
        dueDateDatePicker.isHidden = false
        datePickerButton.isHidden = true
    }
    
    
    //MARK: - Account Picker Delegates
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var stringArray = AccountController.shared.accounts.map { $0.name }
        accountPickerButton.setTitle(stringArray[row], for: .normal)
        accountPickerView.isHidden = true
        accountPickerButton.isHidden = false
    }
    
    func setPickerDelegates() {
        accountPickerView.dataSource = self
        accountPickerView.delegate = self
    }
    
    //MARK: - UIView Setup
    func setUpUI() {
        nameTextField.delegate = self
        initialAmountTextField.delegate = self
        goalAmountTextField.delegate = self
        accountPickerView.isHidden = true
        dueDateDatePicker.isHidden = true
        
        accountPickerButton.setTitle("Choose Account", for: .normal)
        
        //MAY NOT NEED THIS?
        if plannedExpense != nil {
            guard let plannedExpense = plannedExpense else { return }
            
            var stringInitialAmount = String(format: "%.2f", plannedExpense.initialAmount)
            stringInitialAmount.insert("$", at: stringInitialAmount.startIndex)
            
            var stringGoalAmount = String(format: "%.2f", plannedExpense.goalAmount)
            stringGoalAmount.insert("$", at: stringGoalAmount.startIndex)
            
            accountPickerButton.setTitle(plannedExpense.account, for: .normal)
            nameTextField.text = plannedExpense.name
            initialAmountTextField.text = "\(plannedExpense.initialAmount)"
            goalAmountTextField.text = "\(plannedExpense.goalAmount)"
            dueDateDatePicker.date = plannedExpense.dueDate
        }
    }
    
    
    //MARK: - Text Field Properties
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        initialAmountTextField.text = "$"
        goalAmountTextField.text = "$"
    }
    
    //MARK: Formatting Dates
    private func returnFormattedDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM YYYY"
        let strDate = dateFormatter.string(from: dueDateDatePicker.date)
        let date: Date? = dateFormatter.date(from: strDate)
        return date ?? Date()
    }
    
    func returnFormattedDateString() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM YYYY"
        let strDate = dateFormatter.string(from: dueDateDatePicker.date)
        return strDate
    }
    
}


