//
//  PlannedExpenseViewController.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/7/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

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
    @IBOutlet weak var lblAmountContributed: UILabel!
    @IBOutlet weak var lblGreatJob: UILabel!
    @IBOutlet weak var stkDespositAndWithdraw: UIStackView!
    
    // MARK: Properties
    let dueDateDatePicker = UIDatePicker()
    let accountPickerView = UIPickerView()
    let calendar = Calendar.autoupdatingCurrent
    var currentYShiftForKeyboard: CGFloat = 0
    var textFieldBeingEdited: UITextField?
    
    // For Deposit and Withdraw Alerts
    var depositAmountTextField: UITextField?
    var withdrawalAmountTextField: UITextField?
    
    var depositAmount: Double?
    var withdrawAmount: Double?
    
    var plannedExpense: PlannedExpense? {
        didSet {
            if isViewLoaded { setupView() }
        }
    }
    
    //MARK: - View Lifecycles
    override func viewWillAppear(_ animated: Bool) {
        setupView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardNotificaitonObservers()
        setUpUI()
    }
    
    // MARK: - Setup UI
    func setUpUI() {
        setupNavBar()
        setPickerDelegates()
        showDatePicker()
        showAccountPicker()
        hideKeyboard()
    }
    
    func setupNavBar() {
        self.navigationController?.navigationBar.tintColor = .white
        if let plannedExpense = plannedExpense {
            self.navigationItem.title = plannedExpense.name
            self.navigationItem.rightBarButtonItem?.title = "Update"
        } else {
            self.navigationItem.title = "New Savings Goal"
            self.navigationItem.rightBarButtonItem?.title = "Save"
        }
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
    private func setupView() {
        
        if plannedExpense != nil {
            // There is a plannedexpense
            initialAmountTextField.isHidden = true
            initalAmountLabel.isHidden = true
            lblGreatJob.isHidden = false
            lblAmountContributed.isHidden = false
            stkDespositAndWithdraw.isHidden = false
            
            guard let plannedExpense = plannedExpense else {return}
            let total = plannedExpense.totalDeposited
            
            lblAmountContributed.text = "You have contributed: " + formatNumberToString(fromDouble: total)
            txtAccountPicker.text = plannedExpense.account
            nameTextField.text = plannedExpense.name
            goalAmountTextField.text = formatNumberToString(fromDouble: plannedExpense.goalAmount)
            txtDatePicker.text = returnFormattedDateString(date: plannedExpense.dueDate)
            
            let totalDeposited = plannedExpense.totalDeposited
            guard let amountDifference = amountDifference(goalAmount: plannedExpense.goalAmount, initialAmount: totalDeposited),
                let calculatedMonthsToDueDate = calculatedMonthsToDueDate(dueDate: plannedExpense.dueDate, currentDate: Date()) else { return }
            
            
            let monthlyContribution = (amountDifference / Double(calculatedMonthsToDueDate))
            if monthlyContribution > 0 {
                calculatedContributionlabel.text = "\(formatNumberToString(fromDouble: monthlyContribution))"
            } else {
                completeButton.isHidden = false
                idealMonthlyContributionAmountLabel.text = "Congratulations! You have reached your goal!"
            }
        } else {
            // There is no planned expense
            calculatedContributionlabel.isHidden = true
            idealMonthlyContributionAmountLabel.isHidden = true
            stkDespositAndWithdraw.isHidden = true
        }
    }    
    
    // MARK: - Functions
    
    func setupKeyboardNotificaitonObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
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
            
            let dueDate = returnFormattedDate(date: dueDateDatePicker.date)
            let account = AccountController.shared.accounts[ accountPickerView.selectedRow(inComponent: 0)].name
            
            PlannedExpenseController.shared.updatePlannedExpenseWith(name: name, account: account, goalAmount: goalAmount, totalDeposited: plannedExpense.totalDeposited, dueDate: dueDate , plannedExpense: plannedExpense, completion: { (_) in})
        } else {
            // Create
            
            guard let name = nameTextField.text, let plannedexpenseAccount = txtAccountPicker.text, !name.isEmpty, !plannedexpenseAccount.isEmpty else {
                if nameTextField.text == "" {nameTextField.backgroundColor = UIColor.lightPink}
                if txtAccountPicker.text == "" {txtAccountPicker.backgroundColor = UIColor.lightPink}
                return
            }
            
            if PlannedExpenseController.shared.plannedExpenses.contains(where: { $0.name == name }) {
                presentSimpleAlert(controllerToPresentAlert: self, title: "Duplicate Name", message: "You have already planned an expense with this name. Names must be unique!")
                return
            }
            
            
            guard let goalAmount = Double(removeCharactersFromTextField(goalAmountTextField)) else {
                goalAmountTextField.backgroundColor = UIColor.lightPink
                return
            }
            
            guard let initialAmount = Double(removeCharactersFromTextField(initialAmountTextField)) else {
                initialAmountTextField.backgroundColor = UIColor.lightPink
                return
            }
            
            guard let account = AccountController.shared.accounts.first(where: { $0.name == plannedexpenseAccount }) else {return}
            
            PlannedExpenseController.shared.createPlannedExpenseWith(name: name, account: plannedexpenseAccount, goalAmount: goalAmount, dueDate: returnFormattedDate(date: dueDateDatePicker.date), totalDeposited: 0, completion: nil)
            
            
            let transaction = Transaction(date: Date(), monthYearDate: Date(), category: nil, payee: name, transactionType: TransactionType.expense.rawValue , amount: initialAmount, account: account.name)
            
            PlannedExpenseController.shared.createPlannedExpenseTransaction(transaction: transaction, account: account, categoryName: name)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func completeButtonTapped(_ sender: Any) {
        guard let plannedExpense = plannedExpense else {return}
        PlannedExpenseController.shared.remove(plannedexpense: plannedExpense)
        
        presentSimpleAlert(controllerToPresentAlert: self, title: "Congradulations", message: "We are so proud of you for hitting your goal, keep up the good work!") { (done) in
            guard done else {return}
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    @IBAction func DepositButtonPressed(_ sender: Any) {
        
        presentDepositAlert { (done) in
            guard done, let plannedexpense = self.plannedExpense, let despositAmount = self.depositAmount,
                let account = AccountController.shared.accounts.first(where: { $0.name == plannedexpense.account }), let payee = self.plannedExpense?.name else {return}
            
            
            let transaction = Transaction(date: Date(), monthYearDate: Date(), category: nil, payee: payee, transactionType: TransactionType.expense.rawValue, amount: despositAmount, account: plannedexpense.account)
            
            PlannedExpenseController.shared.createPlannedExpenseTransaction(transaction: transaction, account: account, categoryName: payee)
            
            let currencyAmount = formatNumberToString(fromDouble: despositAmount)
            presentSimpleAlert(controllerToPresentAlert: self, title: "Way To Contribute!", message: "You have successfully moved \(currencyAmount) from \(account.name) towards your \(plannedexpense.name) goal!. ", completion: { (done) in
                guard done else {return}
                self.navigationController?.popViewController(animated: true)
            })
            
        }
        
    }
    
    @IBAction func WithdrawButtonPressed(_ sender: Any) {
        presentWithdrawalAlert { (done) in
            guard done, let plannedexpense = self.plannedExpense, let withdrawAmount = self.withdrawAmount,
                let account = AccountController.shared.accounts.first(where: { $0.name == plannedexpense.account }) else {return}
            
            let plannedexpenseTotal = plannedexpense.totalDeposited
            
            if plannedexpenseTotal - withdrawAmount < 0 {
                presentSimpleAlert(controllerToPresentAlert: self, title: "Oh No!", message: "It looks like you are trying to withdraw more than you've contributed. The most you can withdraw is \(plannedexpense.totalDeposited).")
                return
            }
            
            PlannedExpenseController.shared.subtractAmountoTotalDeposited(amount: withdrawAmount, plannedexpense: plannedexpense)
            AccountController.shared.addAmountToAccountWith(amount: withdrawAmount, account: account)
            
            
            presentSimpleAlert(controllerToPresentAlert: self, title: "Success",
                               message: "You have successfully withdrawn " + formatNumberToString(fromDouble: withdrawAmount) + " and it has been added back to \(account.name).", completion: { (done) in
                                guard done else {return}
                                self.navigationController?.popViewController(animated: true)
            })
        }

        
    }
    
    
    //Deposit Alert
    func presentDepositAlert(completion: @escaping(_ done: Bool) -> Void) {
        var depositAmount: UITextField!
        
        let depositAlertController = UIAlertController(title: "Deposit", message: "How much money do you want to deposit into your planned expense?", preferredStyle: .alert)
        
        
        depositAlertController.addTextField { (textField) in
            textField.placeholder = "Amount To Contribute"
            depositAmount = textField
        }
        
        let addAction = UIAlertAction(title: "Deposit", style: .default) { (_) in
            
        
            guard let stringAmount = depositAmount.text, let amountDeposited = Double(stringAmount) else {
                presentSimpleAlert(controllerToPresentAlert: self, title: "Error", message: "You have entered an invalid amount!")
                   completion(false)
                return
            }
            
            self.depositAmount = amountDeposited
            completion(true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) in
            self.view.endEditing(true)
            completion(false)
        }
        
        depositAlertController.addAction(addAction)
        depositAlertController.addAction(cancelAction)
        present(depositAlertController, animated: true, completion: nil)
    }
    
    //Withdrawal Alert
    func presentWithdrawalAlert(completion: @escaping (_ success: Bool) -> Void) {
        
        var withdrawAmount: UITextField!
        
        let withdrawalAlertController = UIAlertController(title: "Withdrawal", message: "How much money do you want to withdraw from your planned expense savings?", preferredStyle: .alert)
        
        withdrawalAlertController.addTextField { (textField) in
            textField.placeholder = "Amount To Withdraw"
            withdrawAmount = textField
        }
        
        let addAction = UIAlertAction(title: "Withdraw", style: .default) { (_) in
            
            guard let stringAmount = withdrawAmount.text, let amount = Double(stringAmount) else {
                presentSimpleAlert(controllerToPresentAlert: self, title: "Error", message: "You have entered an invalid amount!")
                completion(false)
                return
                
            }
            
            self.withdrawAmount = amount
            completion(true)
            self.navigationController?.popViewController(animated: true)
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) in
            self.view.endEditing(true)
        }
        
        withdrawalAlertController.addAction(addAction)
        withdrawalAlertController.addAction(cancelAction)
        present(withdrawalAlertController, animated: true, completion: nil)
    }
    
    //MARK: - Account Picker
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
        txtDatePicker.text = returnFormattedDateString(date: dueDateDatePicker.date)
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





