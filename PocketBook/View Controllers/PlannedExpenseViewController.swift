//
//  PlannedExpenseViewController.swift
//  PocketBook
//
//  Created by Laura O'Brien on 11/6/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

/*STILL NEED:
 
 dueDate needs to be formatted as a date - datepicker
 
 initialAmount is saved as an int for calculations, but comes up as a string
 
 completion?!
 
 1. TotalSaved > Progress Bar
 4. Complete button
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
    @IBOutlet weak var txtDatePicker: UITextField!
    @IBOutlet weak var idealMonthlyContributionAmountLabel: UILabel!
    
    //MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setPickerDelegates()
        showDatePicker()
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
    //    let idealMonthlyContributionAmount = amountDifference(goalAmount: plannedExpense.goalAmount, initialAmount: plannedExpense.initialAmount) / calculatedMonthsToDueDate(dueDate: plannedExpense.dueDate, currentDate: DateHelper.currentDate)
    
    //MARK: - Functions
    private func updateViews() {
        guard let plannedExpense = plannedExpense else { return }
        nameTextField.text = plannedExpense.name
        initialAmountTextField.text = "\(plannedExpense.initialAmount)"
        goalAmountTextField.text = "\(plannedExpense.goalAmount)"
        dueDateDatePicker.date = plannedExpense.dueDate //hook up
        //        idealMonthlyContributionAmountLabel.text = "\(idealMonthlyContributionAmount)"
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
        setUpDepositAlertController()
        //Alert
        //adds an amount to the plannedExpenses array?
        //populates updated progress bar & segues to TVC
        //incomeSaved
        //has a "+" at the beginning of the text field on the alert
    }
    
    
    
    
    @IBAction func withdrawButtonTapped(_ sender: Any) {
        //Alert
        //subtracts an amount from the plannedExpenses array?
        //populates updated progress bar & segues to TVC
        //has a "-" at the beginning of the text field on the alert
    }
    
    @IBAction func completeButtonTapped(_ sender: Any) {
        //        >Creates a transaction, segues to DVC
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if plannedExpense == nil {
            guard let plannedExpense = plannedExpense,
                let account = accountPickerButton.currentTitle,
                let name = nameTextField.text,
                let initialAmount = Double(initialAmountTextField.text!),
                let goalAmount = Double(goalAmountTextField.text!),
                let dueDate = txtDatePicker.text,
                let idealMonthlyContributionAmount = idealMonthlyContributionAmountLabel.text
                else { return }
            
            PlannedExpenseController.shared.createPlannedExpenseWith(name: name, account: account, initialAmount: initialAmount, goalAmount: goalAmount, dueDate: returnFormattedDate(), completion: { (plannedExpense) in
                let plannedExpense = plannedExpense
            })
        
        } else {
            
            guard let plannedExpense = plannedExpense,
            let account = accountPickerButton.currentTitle,
            let name = nameTextField.text,
             let initialAmount = Double(initialAmountTextField.text!),
            let goalAmount = Double(goalAmountTextField.text!),
//            let incomeSaved = ,
            let totalSaved = plannedExpense.totalSaved,
            let dueDate = txtDatePicker.text
            //                let idealMonthlyContributionAmount = idealMonthlyContributionAmountLabel.text
            else { return }
            
            PlannedExpenseController.shared.updatePlannedExpenseWith(name: name, account: account, initialAmount: initialAmount, goalAmount: goalAmount, /*incomeSaved: incomeSaved,*/ totalSaved: totalSaved, dueDate: returnFormattedDate(), plannedExpense: plannedExpense, completion: { (plannedExpense) in
                guard let plannedExpense = plannedExpense else { return }
            })
        }
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Alert Controller
    func updateProgressBar() {
        //.text = plannedExpense?.incomeSaved()
    }
    
    func setUpDepositAlertController() {
        var depositAmountTextField: UITextField?
        func depositTextFieldDidBeginEditing(_ textField: UITextField) {
            depositAmountTextField?.text = "+"
        }
        let depositAlertController = UIAlertController(title: "Deposit", message: "How much money do you want to deposit into your planned expense?", preferredStyle: .alert)
        depositAlertController.addTextField { (textField) in
            textField.placeholder = "Enter amount here"
            depositAmountTextField = textField
        }
        guard let depositAmount = depositAmountTextField?.text,
            let amount = Double(depositAmount) else { return }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) in
            self.updateProgressBar()
        }
        depositAlertController.addAction(cancelAction)
        present(depositAlertController, animated: true, completion: nil)
    }
    
    //MARK: - Custom & Date Picker Button Actions
    @IBAction func accountPickerButtonTapped(_ sender: Any) {
        accountPickerView.isHidden = false
        accountPickerButton.isHidden = true
    }
    
    
    //MARK: - Custom Account Picker Delegates
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
    
    //MARK: - Date Picker Action
    func showDatePicker(){
        dueDateDatePicker.datePickerMode = .date
        
        // ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        // done button & cancel button
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: Selector(("donedatePicker")))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: Selector(("cancelDatePicker")))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        txtDatePicker.inputAccessoryView = toolbar
        txtDatePicker.inputView = dueDateDatePicker
        
    }
    
    func donedatePicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        txtDatePicker.text = formatter.string(from: dueDateDatePicker.date)
        self.view.endEditing(true)
    }
    
    func cancelDatePicker() {
        //cancel button dismiss datepicker dialog
        self.view.endEditing(true)
    }
    
    private  func returnFormattedDate() -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let strDate = dateFormatter.string(from: dueDateDatePicker.date)
        let date: Date? = dateFormatter.date(from: strDate)
        return date ?? Date()
        
    }
    
    //MARK: - UIView Setup
    func setUpUI() {
        nameTextField.delegate = self
        initialAmountTextField.delegate = self
        goalAmountTextField.delegate = self
        accountPickerView.isHidden = true
        dueDateDatePicker.isHidden = true
    }
    //        accountPickerButton.setTitle("Choose Account", for: .normal)
    
    //        //MAY NOT NEED THIS?
    //        if plannedExpense != nil {
    //            guard let plannedExpense = plannedExpense else { return }
    //
    //            var stringInitialAmount = String(format: "%.2f", plannedExpense.initialAmount)
    //            stringInitialAmount.insert("$", at: stringInitialAmount.startIndex)
    //
    //            var stringGoalAmount = String(format: "%.2f", plannedExpense.goalAmount)
    //            stringGoalAmount.insert("$", at: stringGoalAmount.startIndex)
    //
    //            accountPickerButton.setTitle(plannedExpense.account, for: .normal)
    //            nameTextField.text = plannedExpense.name
    //            initialAmountTextField.text = "\(plannedExpense.initialAmount)"
    //            goalAmountTextField.text = "\(plannedExpense.goalAmount)"
    //            dueDateDatePicker.date = plannedExpense.dueDate
    //        }
    
    
    //MARK: - Text Field Properties
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        initialAmountTextField.text = "$"
        goalAmountTextField.text = "$"
    }
}




