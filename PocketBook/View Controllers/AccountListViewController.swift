//
//  AccountListViewController.swift
//  PocketBook
//
//  Created by Michael Meyers on 11/15/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class AccountListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    // MARK: - Properties
    
    var currentYShiftForKeyboard: CGFloat = 0
    var toAccount: Account?
    var fromAccount: Account?
    var payDayAccount: Account?
    var textFieldBeingEdited: UITextField?
    let arrayString: [String] = [
        "Checking",
        "Savings",
        "Credit Card"
    ]
    
    // MARK: - Outlets
    @IBOutlet weak var incomeDetailView: UIView!
    @IBOutlet weak var transferMoneyView: UIView!
    
    @IBOutlet weak var toPickerView: UIPickerView!
    @IBOutlet weak var fromPickerView: UIPickerView!
    @IBOutlet weak var payDayPickerView: UIPickerView!
    
    @IBOutlet weak var transferFundsButton: UIButton!
    @IBOutlet weak var transferViewCancelButton: UIButton!
    @IBOutlet weak var incomeDetailCancelButton: UIButton!
    @IBOutlet weak var payDayButton: UIButton!
    @IBOutlet weak var depositButton: UIButton!
    @IBOutlet weak var transferButton: UIButton!
    
    @IBOutlet weak var transferAmountTextField: UITextField!
    @IBOutlet weak var payDayAmountTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var accountsTotalLabel: UILabel!
    @IBOutlet weak var incomeDetailsLabel: UILabel!
    @IBOutlet weak var transferMoneyLabel: UILabel!
    
    // MARK: - View LifeCyles
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsSignedIntoCloudKit()
        loadAndCheckDate()
        setUpUI()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.updateArrays()
            self.reloadTableView()
        }

        setUpTransferFundsView()
    }
    
    // MARK: - Setup View
    func setUpTransferFundsView( ) {
        incomeDetailView.isHidden = true
        transferMoneyView.isHidden = true
    }
    
    @objc func reloadTableView() {
        DispatchQueue.main.async {
            self.updateArrays()
            self.tableView.reloadData()
            self.fromPickerView.reloadAllComponents()
            self.toPickerView.reloadAllComponents()
            self.payDayPickerView.reloadAllComponents()
            self.fromPickerView.reloadInputViews()
            self.toPickerView.reloadInputViews()
            self.payDayPickerView.reloadInputViews()
            let total = self.totalFundsCalc()
            self.accountsTotalLabel.text = "\(formatNumberToString(fromDouble: total))"
        }
    }
    
    // MARK: Account Arrays
    
    func returnAccountArray(withType type: String) -> [Account] {
        var accountArray: [Account] = []
        for account in AccountController.shared.accounts {
            if account.accountType == type {
                accountArray.append(account)
            }
        }
        return accountArray
    }
    
    // Make arrays for all accounts
    var checkingArray: [Account]?
    var savingsArray: [Account]?
    var creditArray: [Account]?
    
    func updateArrays() {
        
        // FIXME: Implement Enums and remove raw values below
        self.checkingArray = returnAccountArray(withType: SegmentedControlType.checking.rawValue)
        self.savingsArray = returnAccountArray(withType: SegmentedControlType.saving.rawValue)
        self.creditArray = returnAccountArray(withType: SegmentedControlType.credit.rawValue)
    }
    
    // This function checks to see if there is anything in the array for each type of account. It then returns an array of arrays with the accounts grouped in their respective arrays.
    func returnAllAccounts() -> [[Account]] {
        
        self.updateArrays()
        var allAccounts: [[Account]] = []
        
        guard let checkingArray = self.checkingArray,
            let savingsArray = self.savingsArray,
            let creditArray = self.creditArray else { return [] }
        
        if checkingArray.count > 0 {
            allAccounts.append(checkingArray)
        }
        if savingsArray.count > 0 {
            allAccounts.append(savingsArray)
        }
        if creditArray.count > 0 {
            allAccounts.append(creditArray)
        }
        
        return allAccounts.flatMap({ $0 })
    }
    
    /// This function checks to see if there is anything in the array for each type of account. It then returns an array with section names. This function is needed so that the tableview can count the number of sections.
    func returnAllSections() -> [String] {
        
        self.updateArrays()
        var allSections: [String] = []
        
        guard let checkingArray = self.checkingArray,
            let savingsArray = self.savingsArray,
            let creditArray = self.creditArray else { return [] }
        
        
        if checkingArray.count > 0 {
            allSections.append(AccountType.Checking.rawValue)
        }
        if savingsArray.count > 0 {
            allSections.append(AccountType.Saving.rawValue)
        }
        if creditArray.count > 0 {
            allSections.append(AccountType.Credit.rawValue)
        }
        
        return allSections
    }
    
    // MARK: - Setup TableView
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let checkingArray = self.checkingArray,
            let savingsArray = self.savingsArray,
            let creditArray = self.creditArray else { return nil }
        
        let checkingTotal = AccountController.shared.addUpAccountAmounts(fromAccountArray: checkingArray)
        let savingsTotal = AccountController.shared.addUpAccountAmounts(fromAccountArray: savingsArray)
        let creditTotal = AccountController.shared.addUpAccountAmounts(fromAccountArray: creditArray)
        
        switch section {
        case 0:
            if checkingArray.isEmpty == false {
                return updateAccountHeader(withname: "Checking Account", basedOnArray: checkingArray) + ": \(formatNumberToString(fromDouble: checkingTotal))"
            } else { fallthrough }
        case 1:
            if savingsArray.isEmpty == false {
                return updateAccountHeader(withname: "Savings Account", basedOnArray: savingsArray) + ": \(formatNumberToString(fromDouble: savingsTotal))"
            } else { fallthrough }
        default:
            if creditArray.isEmpty == false {
                return updateAccountHeader(withname: "Credit Account", basedOnArray: creditArray) + ": \(formatNumberToString(fromDouble: creditTotal))"
            }
        }
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.returnAllSections().count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.returnAllAccounts()[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath)
    
        let account = self.returnAllAccounts()[indexPath.section][indexPath.row]
        cell.textLabel?.text = account.name
        
        let stringAmount = formatNumberToString(fromDouble: account.total)
        cell.detailTextLabel?.text = stringAmount
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let alertController = UIAlertController(title: "Delete Account", message: "Please confirm that you want to delete this account. Deleting this account will delete all corresponding transactions and planned expenses. If you want to preserve all current and historical data associated with this account, tap on the account and mark the account as closed. Deleting this account cannot be udone.", preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                
                // Delete Account from cloudKit and from accounts array
                let numberOfRowsInSection = self.returnAllAccounts()[indexPath.section].count
                let account = self.returnAllAccounts()[indexPath.section][indexPath.row]
                let intIndex = AccountController.shared.getIntIndex(forAccount: account)
                AccountController.shared.delete(account: account)
                AccountController.shared.accounts.remove(at: intIndex)
                
                // Delete selected row
                if numberOfRowsInSection == 1 {
                    tableView.deleteSections([indexPath.section], with: .fade)
                } else {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                
                // When an account is deleted, delete all corresponding transactions
                for transaction in TransactionController.shared.transactions {
                    if transaction.account == account.name {
                        let updatedTransactions = TransactionController.shared.transactions.filter { $0.account != account.name }
                        TransactionController.shared.transactions = updatedTransactions
                        TransactionController.shared.delete(transaction: transaction)
                    }
                }
                
                // When an account is deleted, delete all corresponding budget items
                for plannedExpense in PlannedExpenseController.shared.plannedExpenses {
                    if plannedExpense.account == account.name {
                        let updatedTransactions = PlannedExpenseController.shared.plannedExpenses.filter { $0.account != account.name }
                        PlannedExpenseController.shared.plannedExpenses = updatedTransactions
                        PlannedExpenseController.shared.delete(plannedExpense: plannedExpense)
                    }
                }
            }
            
            // Alert
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Picker View Delegate and DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let accounts = AccountController.shared.accounts.count
        return accounts
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let accounts = AccountController.shared.accounts
        return accounts[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == payDayPickerView {
            let index = pickerView.selectedRow(inComponent: component)
            let account =  AccountController.shared.accounts[index]
            payDayAccount = account
        }
        if pickerView == toPickerView {
            let index = pickerView.selectedRow(inComponent: component)
            let account =  AccountController.shared.accounts[index]
            toAccount = account
        }
        if pickerView == fromPickerView {
            let index = pickerView.selectedRow(inComponent: component)
            let account =  AccountController.shared.accounts[index]
            fromAccount = account
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let accounts = AccountController.shared.accounts
        let account = accounts[row]
        pickerLabel.text = account.name
        pickerLabel.font = UIFont(name: "Arial", size: 15)
        pickerLabel.textAlignment = .center
        return pickerLabel
    }
    
    // MARK: - TextFields
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

    func stopEditingTextField() {
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldBeingEdited = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    // MARK: - Actions
    
    @IBAction func transferButtonFundsTapped(_ sender: UIButton) {
        transferMoneyView.isHidden = false
        incomeDetailView.isHidden = true
    }
    
    @IBAction func payDayButtonTapped(_ sender: UIButton) {
        incomeDetailView.isHidden = false
        transferMoneyView.isHidden = true
    }
    
    @IBAction func incomeDetailsCancelButtonTapped(_ sender: UIButton) {
        resetIncomeDetailView()
    }
    
    @IBAction func transferMoneyCancelButtonTapped(_ sender: UIButton) {
        resetTransferMoneyView()
    }
    
    @IBAction func depostiButtonTapped(_ sender: UIButton) {
        // TODO: ADDED SIMPLE ARE YOU SURE ALERT
        guard let amountString = payDayAmountTextField.text, amountString != "",
            let amount = Double(amountString),
            let account = payDayAccount else {return}
        
        account.total += amount
        tableView.reloadData()
        AccountController.shared.updateAccountWith(name: account.name, type: account.accountType, total: account.total, account: account) { (_) in
            // Nothing to do.
        }
        resetIncomeDetailView()
    }
    
    @IBAction func transferButtonTapped(_ sender: UIButton) {
        // TODO: ADDED SIMPLE ARE YOU SURE ALERT
        guard let amountString = transferAmountTextField.text, amountString != "",
            let amount = Double(amountString),
            let toAccount = toAccount,
            let fromAccount = fromAccount else {
                return
        }
        
        fromAccount.total -= amount
        toAccount.total += amount
        tableView.reloadData()
        AccountController.shared.updateAccountWith(name: toAccount.name, type: toAccount.accountType, total: toAccount.total, account: toAccount, completion:  { (_) in
            // TODO: DELETE THIS CLOSURE
        })
        AccountController.shared.updateAccountWith(name: fromAccount.name, type: fromAccount.accountType, total: fromAccount.total, account: fromAccount, completion: { (_) in
            // TODO: DELETE THIS CLOSURE
        })
        resetTransferMoneyView()
    }
    
    // MARK: Button Functions
    func resetIncomeDetailView() {
        incomeDetailView.isHidden = true
        payDayAmountTextField.text = ""
        payDayPickerView.reloadAllComponents()
    }
    
    func resetTransferMoneyView() {
        transferMoneyView.isHidden = true
        transferAmountTextField.text = ""
        toPickerView.reloadAllComponents()
        fromPickerView.reloadAllComponents()
    }
    
    // MARK: - Methods
    func setUpUI() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: Notifications.accountWasUpdatedNotification, object: nil)
        
        setUpDelegates()
        updateArrays()
        addTapGesture()
        updateTotalLabel()

    }
    
    func updateTotalLabel() {
        let total = totalFundsCalc()
        accountsTotalLabel.text = formatNumberToString(fromDouble: total)
    }
    
    func addTapGesture() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    func setUpDelegates() {
        toPickerView.delegate = self
        toPickerView.dataSource = self
        fromPickerView.dataSource = self
        fromPickerView.delegate = self
        payDayPickerView.dataSource = self
        payDayPickerView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        transferAmountTextField.delegate = self
        payDayAmountTextField.delegate = self
    }
    
    func checkIfUserIsSignedIntoCloudKit() {
        let cloudKitManager = CloudKitManager()
        if cloudKitManager.checkIfUserIsSignedIntoCloudKit() == false {
            presentSimpleAlert(controllerToPresentAlert: self, title: "Warning!", message: "You are not signed into iCloud, which means your data will not be saved! Go into settings and turn on iCloud.")
        }
    }
    
    // MARK: - Calculations
    func totalFundsCalc() -> Double {
        var total: Double = 0.0
        for account in AccountController.shared.accounts {
            if account.accountType == AccountType.Credit.rawValue {
                total = total - account.total
            } else {
                total += account.total
            }
        }
        return total
    }
    
    // MARK: - Alert Methods
    func presentResetMonthlyBudgetAlert() {
        let alertController = UIAlertController(title: "Reset Budget Categories", message: "It is a new Month! Would you like to reset each of your budget categories to show no money spent?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            BudgetItemController.shared.resetSpentTotal()
        }
        let noAction = UIAlertAction(title: "No", style: .default) { (_) in
            var monthString = ""
            var yearString = ""
            let dayString = "01"
            let currentYear = dateComponentYear(date: Date())
            let currentMonth = dateComponentMonth(date: Date())
            if currentMonth == 1 {
                monthString = "12"
                yearString = "\(currentYear - 1)"
            } else {
                let lastMonth = currentMonth - 1
                if lastMonth <= 9 {
                    monthString = "0\(lastMonth)"
                } else {
                    monthString = "\(lastMonth)"
                }
                yearString = "\(currentYear)"
                let date = Date(dateString: yearString+"-"+monthString+"-"+dayString)
                //"yyyy-MM-dd"
                print(date)
                
                self.saveDate(date: date)
            }
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - USER DEFAULT
    func loadAndCheckDate() {
        let userDefaults = UserDefaults.standard
        guard let dateDictionary = userDefaults.object(forKey: Keys.dateDictionaryKey) as? [String: Date],
            let date = dateDictionary[Keys.dateDictionaryKey] else {
                let lastTimeAppWasOpened = Date()
                saveDate(date: lastTimeAppWasOpened)
                return}
        let currentDate = Date()
        let currentMonth = dateComponentMonth(date: currentDate)
        let currentYear = dateComponentYear(date: currentDate)
        let dateMonth = dateComponentMonth(date: date)
        let dateYear = dateComponentYear(date: date)
        
        if dateYear < currentYear {
            let lastTimeAppWasOpened = Date()
            saveDate(date: lastTimeAppWasOpened)
            presentResetMonthlyBudgetAlert()
            let plannedExpenses = PlannedExpenseController.shared.plannedExpenses
            for plannedExpense in plannedExpenses {
                plannedExpense.monthlyTotals.append(plannedExpense.totalSaved ?? 0)
            }
        }
        if dateMonth < currentMonth {
            presentResetMonthlyBudgetAlert()
            let lastTimeAppWasOpened = Date()
            saveDate(date: lastTimeAppWasOpened)
            let plannedExpenses = PlannedExpenseController.shared.plannedExpenses
            for plannedExpense in plannedExpenses {
                if plannedExpense.monthlyTotals.count == 12 {
                    plannedExpense.monthlyTotals.remove(at: 11)
                    plannedExpense.monthlyTotals.append(plannedExpense.totalSaved ?? 0)
                } else {
                    plannedExpense.monthlyTotals.append(plannedExpense.totalSaved ?? 0)
                }
            }
        } else {
            let lastTimeAppWasOpened = Date()
            saveDate(date: lastTimeAppWasOpened)
        }
    }
    
    func saveDate(date: Date) {
        let userDefaults = UserDefaults.standard
        let dateDictionary: [String: Date] = [Keys.dateDictionaryKey: date]
        userDefaults.set(dateDictionary, forKey: Keys.dateDictionaryKey)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toAccountDetail" {
            
            guard let destinationVC = segue.destination as? AccountDetailsViewController, let indexPath = tableView.indexPathForSelectedRow else {return}
            
            destinationVC.account = self.returnAllAccounts()[indexPath.section][indexPath.row]
        }
    }
}

