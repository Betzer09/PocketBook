//
//  PlannedExpenseViewController.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/7/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

/*TO DO:
 
 txtAccountPicker.text - func
 Complete button -> Transaction
 
 * bonus: Ideal Monthly Contribution calculations
 
 */

class PlannedExpenseDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var txtAccountPicker: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var initialAmountTextField: UITextField!
    @IBOutlet weak var goalAmountTextField: UITextField!
    @IBOutlet weak var txtDatePicker: UITextField!
    @IBOutlet weak var idealMonthlyContributionAmountLabel: UILabel!
    @IBOutlet weak var calculatedContributionlabel: UILabel!
    @IBOutlet weak var initalAmountLabel: UILabel!
    
    // MARK: Properties
    let dueDateDatePicker = UIDatePicker()
    let accountPickerView = UIPickerView()
    let calendar = Calendar.autoupdatingCurrent
    var currentYShiftForKeyboard: CGFloat = 0
    var textFieldBeingEdited: UITextField?
    
    var plannedExpense: PlannedExpense? {
        didSet {
            if isViewLoaded { configureUIWhenPlannedExpenseCellIsPressed() }
        }
    }
    
    //MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        if let plannedExpense = plannedExpense {
            self.navigationItem.title = plannedExpense.name
            self.navigationItem.rightBarButtonItem?.title = "Update"
        } else {
            self.navigationItem.title = "New Savings Goal"
            self.navigationItem.rightBarButtonItem?.title = "Save"
        }
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        configureUIWhenPlannedExpenseCellIsPressed()
    }
    
    // MARK: - Setup UI
    func setUpUI() {
        self.navigationController?.navigationBar.tintColor = .white
        setPickerDelegates()
        showDatePicker()
        showAccountPicker()
        hideKeyboard()
        roundButtons()
    }
    
    func roundButtons() {

        completeButton.layer.cornerRadius = completeButton.frame.height/4
    }
    
    func resizeButtonTitles() {
        completeButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    /// Check to see if the user deletes or keeps the "$" when updating account. Drop first character if the user chooses not the delete the "$".
    func dropFirstCharacterFrom(textField: UITextField) -> String? {
        
        var outputString: String = ""
        guard let string = textField.text else { return nil }
        if string.contains("$") {
            outputString = String(string.dropFirst())
        } else {
            outputString = String(string)
        }
        return outputString
    }
    
    /// Populates the view if a Planned Expense cell has been pressed
    private func configureUIWhenPlannedExpenseCellIsPressed() {
        
        if plannedExpense != nil {
            
            initialAmountTextField.isHidden = true
            initalAmountLabel.isHidden = true

            guard let plannedExpense = plannedExpense else {return}
            
            txtAccountPicker.text = plannedExpense.account
            nameTextField.text = plannedExpense.name
            goalAmountTextField.text = formatNumberToString(fromDouble: plannedExpense.goalAmount)
            initialAmountTextField.text = formatNumberToString(fromDouble: plannedExpense.initialAmount)
            txtDatePicker.text = returnFormattedDateString(date: plannedExpense.dueDate)
            
            let totalDeposited = plannedExpense.totalDeposited
            let initialAmount = plannedExpense.initialAmount
            guard let amountDifference = amountDifference(goalAmount: plannedExpense.goalAmount, initialAmount: totalDeposited + initialAmount),
                let calculatedMonthsToDueDate = calculatedMonthsToDueDate(dueDate: plannedExpense.dueDate, currentDate: Date()) else { return }
            
            
            let monthlyContribution = (amountDifference / Double(calculatedMonthsToDueDate))
            if monthlyContribution > 0 {
                calculatedContributionlabel.text = "\(formatNumberToString(fromDouble: monthlyContribution))"
            } else {
                completeButton.isHidden = false
                idealMonthlyContributionAmountLabel.text = "Congratulations! You have reached your goal!"
            }
        } else {
            calculatedContributionlabel.isHidden = true
            idealMonthlyContributionAmountLabel.isHidden = true
        }
    }    
    
    // MARK: - Methods
    
    /// This function calculates the remaining amount needed to reach goal
    func amountDifference(goalAmount: Double, initialAmount: Double) -> Double? {
        let difference = goalAmount - initialAmount
        if difference >= 0 {
            return difference
        } else {
            return 0.0
        }
    }
    
    /// This function calculates the number of months between two dates
    func calculatedMonthsToDueDate(dueDate: Date, currentDate: Date) -> Int? {
        let dueDateComponents = calendar.dateComponents([.year, .month], from: dueDate)
        let currentDateComponents = calendar.dateComponents([.year, .month], from: currentDate)
        guard let dueDateYear = dueDateComponents.year,
            let dueDateMonth = dueDateComponents.month,
            let currentMonth = currentDateComponents.month,
            let currentYear = currentDateComponents.year else { return nil }
        let yearRemainder = dueDateYear - currentYear
        let monthRemainder = (dueDateMonth - currentMonth)
        let total = ((yearRemainder * 12) + monthRemainder) + 1
        return total
    }
    
    //MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        if plannedExpense != nil {
            // Update
            guard let plannedExpense = plannedExpense,
                let name = nameTextField.text, !name.isEmpty else {return}
            
            guard let goalAmount = Double(removeCharactersFromTextField(goalAmountTextField)) else {
                goalAmountTextField.backgroundColor = UIColor.lightPink
                return
            }
            guard let initialAmount = Double(removeCharactersFromTextField(initialAmountTextField)) else {
                initialAmountTextField.backgroundColor = UIColor.lightPink
                return
            }
            
            let dueDate = returnFormattedDate(date: dueDateDatePicker.date)
            let account = AccountController.shared.accounts[ accountPickerView.selectedRow(inComponent: 0)].name
            
            PlannedExpenseController.shared.updatePlannedExpenseWith(name: name, account: account, initialAmount: initialAmount, goalAmount: goalAmount, amountDeposited: plannedExpense.amountDeposited, amountWithdrawn: plannedExpense.amountWithdrawn, totalDeposited: plannedExpense.totalDeposited, dueDate: dueDate , plannedExpense: plannedExpense, completion: { (_) in})
            
        } else {
            // Create
            
            guard let name = nameTextField.text, let account = txtAccountPicker.text, !name.isEmpty, !account.isEmpty else {
                if nameTextField.text == "" {nameTextField.backgroundColor = UIColor.lightPink}
                if txtAccountPicker.text == "" {txtAccountPicker.backgroundColor = UIColor.lightPink}
                return
            }
            
            if PlannedExpenseController.shared.plannedExpenses.contains(where: { $0.name == name }) {
                presentSimpleAlert(controllerToPresentAlert: self, title: "Duplicate Name", message: "You have already planned an expense with this name. Names must be unique!")
            }
            
            
            guard let goalAmount = Double(removeCharactersFromTextField(goalAmountTextField)) else {
                goalAmountTextField.backgroundColor = UIColor.lightPink
                return
            }
            
            guard let initialAmount = Double(removeCharactersFromTextField(initialAmountTextField)) else {
                initialAmountTextField.backgroundColor = UIColor.lightPink
                return
            }
            
            
            PlannedExpenseController.shared.createPlannedExpenseWith(name: name, account: account, initialAmount: initialAmount, goalAmount: goalAmount, dueDate: returnFormattedDate(date: dueDateDatePicker.date), completion: nil)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func completeButtonTapped(_ sender: Any) {
        guard let plannedExpense = plannedExpense else {return}
        PlannedExpenseController.shared.delete(plannedExpense: plannedExpense)
    }
    
    //MARK: - ALERT CONTROLLERS
    var depositAmountTextField: UITextField?
    var withdrawalAmountTextField: UITextField?
    
    //Deposit Alert
    func presentDepositAlert() {
        
        var depositAmount: UITextField!
        
        let depositAlertController = UIAlertController(title: "Deposit", message: "How much money do you want to deposit into your planned expense?", preferredStyle: .alert)
        depositAlertController.addTextField { (textField) in
            textField.placeholder = "Enter amount here"
            textField.text = "+"
            depositAmount = textField
        }
        
        let addAction = UIAlertAction(title: "Deposit", style: .default) { (_) in
            
            guard let StringAmount = depositAmount.text?.dropFirst() else {
                return
            }
            
            guard let amountDeposited = Double(StringAmount) else {
                presentSimpleAlert(controllerToPresentAlert: self, title: "Error", message: "You have entered an invalid amount!")
                return
            }
            guard let plannedExpense = self.plannedExpense else {return}
            plannedExpense.totalDeposited += amountDeposited
            
            PlannedExpenseController.shared.updatePlannedExpenseWith(name: plannedExpense.name, account: plannedExpense.account, initialAmount: plannedExpense.initialAmount, goalAmount: plannedExpense.goalAmount, amountDeposited: amountDeposited, amountWithdrawn: 0.0, totalDeposited: plannedExpense.totalDeposited, dueDate: plannedExpense.dueDate, plannedExpense: plannedExpense, completion: { (_) in })
            
            self.navigationController?.popViewController(animated: true)
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
        
        var withdrawAmount: UITextField!
        
        let withdrawalAlertController = UIAlertController(title: "Withdrawal", message: "How much money do you want to withdraw from your planned expense savings?", preferredStyle: .alert)
        
        withdrawalAlertController.addTextField { (textField) in
            textField.placeholder = "Amount You Want To Remove"
            textField.text = "-"
            withdrawAmount = textField
        }
        
        let addAction = UIAlertAction(title: "Withdraw", style: .default) { (_) in
            
            guard let StringAmount = withdrawAmount.text?.dropFirst() else {
                return
            }
            
            guard let amount = Double(StringAmount) else {
                presentSimpleAlert(controllerToPresentAlert: self, title: "Error", message: "You have entered an invalid amount!")
                return
                
            }
            
            guard let plannedExpense = self.plannedExpense else {return}
            plannedExpense.totalDeposited -= amount
            
            PlannedExpenseController.shared.updatePlannedExpenseWith(name: plannedExpense.name, account: plannedExpense.account, initialAmount: plannedExpense.initialAmount, goalAmount: plannedExpense.goalAmount, amountDeposited: 0.0, amountWithdrawn: amount, totalDeposited: plannedExpense.totalDeposited, dueDate: plannedExpense.dueDate, plannedExpense: plannedExpense, completion: { (_) in })
            
            self.navigationController?.popViewController(animated: true)
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
        toolbar.setItems([cancelButton, spaceButton,doneButton], animated: false)
        txtAccountPicker.inputAccessoryView = toolbar
        txtAccountPicker.inputView = accountPickerView
    }
    
    @objc func doneAccountPicker() {
        
        let count = AccountController.shared.accounts.count
        
        if count < 1 {
            presentSimpleAlert(controllerToPresentAlert: self, title: "Warning", message: "You need to add a Checking or Savings account before you can spend money")
            return
        }
        
        let account = AccountController.shared.accounts[accountPickerView.selectedRow(inComponent: 0)]
        txtAccountPicker.text = account.name
        self.view.endEditing(true)
        
    }
    
    @objc func cancelAccountPicker() {
        self.view.endEditing(true)
    }
    
    // MARK: - Date Picker
    func showDatePicker(){
        if plannedExpense == nil {
            dueDateDatePicker.date = Date()
        }
        dueDateDatePicker.datePickerMode = .date
        dueDateDatePicker.minimumDate = Date()
        // ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        // done button & cancel button
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donedatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelDatePicker))
        toolbar.setItems([cancelButton, spaceButton,doneButton], animated: false)
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
        
        textFieldBeingEdited = textField
        
        if textField == initialAmountTextField {
            initialAmountTextField.text = "$"
        } else if textField == goalAmountTextField {
            goalAmountTextField.text = "$"
        } else if textField == depositAmountTextField {
            depositAmountTextField?.text = "+ "
        } else if textField == withdrawalAmountTextField {
            withdrawalAmountTextField?.text = "- "
        } else {
            print("Error \(#file)")
        }
        
    }
    
    //MARK: - KEYBOARD METHODS
    //(tap gesture anywhere off the keyboard view hides the keyboard)
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(PlannedExpenseDetailViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Keyboard Constraints
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
    
    @objc func keyboardDismissed() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        if self.view.frame.origin.y != 0 {
            
            self.view.frame.origin.y += currentYShiftForKeyboard
        }
        
        stopEditingTextField()
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
    
    func stopEditingTextField() {
        view.endEditing(true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}





