//
//  PlannedExpenseViewController.swift
//  PocketBook
//
//  Created by Laura O'Brien on 11/6/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

/*TO DO:
 
 save button - completions
 incomeSaved
 txtAccountPicker.text
 
 finish buttons
 
 move up constraints when the keyboard comes up for text fields, not pickers (using toolbars)
 
 totalSaved calculations
 TotalSaved -> Progress Bar on TVC
 Complete button -> Transaction
 Ideal Monthly Contribution calculations
 
 */

class PlannedExpenseViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: - Outlets
    @IBOutlet weak var depositButton: UIButton!
    @IBOutlet weak var withdrawButton: UIButton!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var txtAccountPicker: UITextField!
    let accountPickerView = UIPickerView()
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var initialAmountTextField: UITextField!
    @IBOutlet weak var goalAmountTextField: UITextField!
    @IBOutlet weak var txtDatePicker: UITextField!
    let dueDateDatePicker = UIDatePicker()
    @IBOutlet weak var idealMonthlyContributionAmountLabel: UILabel!
    
    //MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setPickerDelegates()
        showDatePicker()
        showAccountPicker()
        hideKeyboard()
    }
    
    //MARK: - Properties
    let calendar = Calendar.autoupdatingCurrent
    
    var plannedExpense: PlannedExpense? {
        didSet {
            if isViewLoaded { updateViews() }
        }
    }
    
    
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
    
    
    //Ideal Monthly Contribution Calculations
    func amountDifference(goalAmount: Int, initialAmount: Int) -> Int? {
        let difference = goalAmount - initialAmount
        return difference
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
    //    let idealMonthlyContributionAmount = amountDifference(goalAmount: plannedExpense.goalAmount, initialAmount: plannedExpense.initialAmount) / calculatedMonthsToDueDate(dueDate: plannedExpense.dueDate, currentDate: DateHelper.currentDate)
    
    
    //MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let account = txtAccountPicker.text,
            let name = nameTextField.text,
            let initialAmount = Double(initialAmountTextField.text!),
            let goalAmount = Double(goalAmountTextField.text!),
            //            let dueDate = txtDatePicker.text,
            let totalSaved = plannedExpense?.totalSaved
            //            let idealMonthlyContributionAmount = idealMonthlyContributionAmountLabel.text
            else { return }
        let date = dueDateDatePicker.date
        
        guard let plannedExpense = self.plannedExpense else {
            PlannedExpenseController.shared.createPlannedExpenseWith(name: name, account: account, initialAmount: initialAmount,goalAmount: goalAmount, dueDate: returnFormattedDate(date: date), completion: { (_) in
//                let plannedExpense = self.plannedExpense
                self.navigationController?.popViewController(animated: true)
            })
            return
        }
        
        PlannedExpenseController.shared.updatePlannedExpenseWith(name: name, account: account, initialAmount: initialAmount, goalAmount: goalAmount, /*incomeSaved: incomeSaved,*/ totalSaved: totalSaved, dueDate: returnFormattedDate(date: date), plannedExpense: plannedExpense, completion: { (_) in
//            guard let plannedExpense = self.plannedExpense else { return }
        })
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func depositButtonTapped(_ sender: Any) {
        presentDepositAlert()
    }
    
    @IBAction func withdrawButtonTapped(_ sender: Any) {
        presentWithdrawalAlert()
    }
    
    @IBAction func completeButtonTapped(_ sender: Any) {
        //        >Creates a transaction, segues to DVC
    }
    
    //MARK: - ALERT CONTROLLERS
    var depositAmountTextField: UITextField?
    var withdrawalAmountTextField: UITextField?
    
    func updateProgressBar() {
//        progress bar progress = plannedExpense?.incomeSaved()
//        let depositAmount = depositAmountTextField?.text
//        let withdrawalAmount = withdrawalAmountTextField?.text
//        let incomeSavedSaved = depositAmount - withdrawalAmount
    }
    
    //Deposit Alert
    func presentDepositAlert() {
        
        let depositAlertController = UIAlertController(title: "Deposit", message: "How much money do you want to deposit into your planned expense?", preferredStyle: .alert)
        depositAlertController.addTextField { (textField) in
            textField.placeholder = "Enter amount here"
            self.depositAmountTextField = textField
            self.textFieldDidBeginEditing(self.depositAmountTextField!)
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (_) in
            self.updateProgressBar()
            //adds an amount to the plannedExpenses array?
            //populates updated progress bar & segues to TVC
            //incomeSaved
        }
        
        depositAlertController.addAction(addAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) in
            self.view.endEditing(true)
        }
        
        depositAlertController.addAction(cancelAction)
        present(depositAlertController, animated: true, completion: nil)
    }
    
    //Withdrawal Alert
    func presentWithdrawalAlert() {
        
        let withdrawalAlertController = UIAlertController(title: "Withdrawal", message: "How much money do you want to withdraw from your planned expense savings?", preferredStyle: .alert)
        withdrawalAlertController.addTextField { (textField) in
            textField.placeholder = "Enter amount here"
            self.withdrawalAmountTextField = textField
            self.textFieldDidBeginEditing(self.withdrawalAmountTextField!)
        }
        
        let addAction = UIAlertAction(title: "Withdraw", style: .default) { (_) in
            self.updateProgressBar()
            //subtracts an amount from the updateprogressBar
            //populates updated progress bar & segues to TVC
        }
        
        withdrawalAlertController.addAction(addAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) in
            self.view.endEditing(true)
        }
        
        withdrawalAlertController.addAction(cancelAction)
        present(withdrawalAlertController, animated: true, completion: nil)
    }
    
    //MARK: - ACCOUNT PICKER
    //Delegates & Setup
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
//        var stringArray = AccountController.shared.accounts.map { $0.name }
    }
    
    func setPickerDelegates() {
        accountPickerView.dataSource = self
        accountPickerView.delegate = self
    }
    
    //Toolbar Configuration
    func showAccountPicker(){
        // ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        // done button & cancel button
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(doneAccountPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelAccountPicker))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        txtAccountPicker.inputAccessoryView = toolbar
        txtAccountPicker.inputView = accountPickerView
    }
    
    @objc func doneAccountPicker() {
        let accountNameArray = AccountController.shared.accounts.map { $0.name }
        ///want indexPath.row to display like //let noteDetail = NoteDetailController.sharedInstance.noteDetails[indexPath.row]
        
        let accountName = accountNameArray
        txtAccountPicker.text = "\(accountName)"
        self.view.endEditing(true)
    }
    
    @objc func cancelAccountPicker() {
        self.view.endEditing(true)
    }
    
    //MARK: - DATE PICKER
    /*NOTE - if we want to make the PICKER to be month & year only, it has to be a custom picker, not a date picker*/
    
    func showDatePicker(){
        dueDateDatePicker.datePickerMode = .date
        
        // ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        // done button & cancel button
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donedatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelDatePicker))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        txtDatePicker.inputAccessoryView = toolbar
        txtDatePicker.inputView = dueDateDatePicker
        
    }
    
    @objc func donedatePicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        txtDatePicker.text = formatter.string(from: dueDateDatePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker() {
        self.view.endEditing(true)
    }
    
    
    //MARK: - Text Field Properties
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        initialAmountTextField.text = "$"
        goalAmountTextField.text = "$"
        depositAmountTextField?.text = "+ $"
        withdrawalAmountTextField?.text = "- $"
        
    }
    
    //MARK: - KEYBOARD (tap gesture anywhere off the keyboard view hides the keyboard)
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(PlannedExpenseViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}




