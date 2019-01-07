//
//  AccountListViewController.swift
//  PocketBook
//
//  Created by Michael Meyers on 11/15/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class AccountListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    var currentYShiftForKeyboard: CGFloat = 0
    var toAccount: Account?
    var fromAccount: Account?
    var payDayAccount: Account?
    let accountPickerView = UIPickerView()
    var textFieldBeingEdited: UITextField?
    let arrayString: [String] = [
        "Checking",
        "Savings",
        "Credit Card"
    ]
    
    // MARK: - Outlets
    @IBOutlet weak var incomeDetailView: UIView!
    @IBOutlet weak var transferMoneyView: UIView!
    
    @IBOutlet weak var toAccountTxtField: UITextField!
    @IBOutlet weak var fromAccountTxtField: UITextField!
    
    @IBOutlet weak var transferFundsButton: UIButton!
    @IBOutlet weak var transferViewCancelButton: UIButton!
    @IBOutlet weak var incomeDetailCancelButton: UIButton!
    @IBOutlet weak var payDayButton: UIButton!
    @IBOutlet weak var depositButton: UIButton!
    @IBOutlet weak var transferButton: UIButton!
    
    @IBOutlet weak var transferAmountTextField: UITextField!
    @IBOutlet weak var payDayAmountTextField: UITextField!
    @IBOutlet weak var paydayAccountTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var accountsTotalLabel: UILabel!
    @IBOutlet weak var incomeDetailsLabel: UILabel!
    @IBOutlet weak var transferMoneyLabel: UILabel!
    @IBOutlet weak var availableBalanceLabel: UILabel!
    
    @IBOutlet weak var noDataImage: UIImageView!
    
    // MARK: - View LifeCyles
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.updateArrays()
            self.noDataImageSetup()
        }
        setUpTransferFundsView()
        updateTotalLabel()
        reloadTableView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsSignedIntoCloudKit()
        loadAndCheckDate()
        setUpUI()
    }
    
    // MARK: - Setup View
    
    func setUpUI() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: Notifications.accountWasUpdatedNotification, object: nil)
        
        setUpDelegates()
        updateArrays()
        addTapGesture()
        updateTotalLabel()
        createPlusButton()
        createQuestionMarkButton()
        roundButtons()
        configureNavigationBar()
    }
    
    func showAccountPickerfor(txtfield: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAccountPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(stopEditingTextField))
        
        toolbar.setItems([cancelButton, spaceButton,doneButton], animated: false)
        txtfield.inputAccessoryView = toolbar
        txtfield.inputView = accountPickerView
        
    }
    
    func noDataImageSetup() {
        let accounts = AccountController.shared.accounts
        if accounts.count == 0 {
            noDataImage.isHidden = false
        } else {
            noDataImage.isHidden = true
        }
    }
    
    func configureNavigationBar() {
        guard let font = UIFont(name: "Avenir Next", size: 17) else {return}
        let attributes = [ NSAttributedStringKey.font: font,
                           NSAttributedStringKey.foregroundColor : UIColor.white,
                           ]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.navigationItem.title = self.navigationItem.title
    }
    
    func setUpTransferFundsView( ) {
        incomeDetailView.isHidden = true
        transferMoneyView.isHidden = true
    }
    
    @objc func reloadTableView() {
        DispatchQueue.main.async {
            self.updateArrays()
            self.fromAccountTxtField.reloadInputViews()
            self.toAccountTxtField.reloadInputViews()
            let total = self.totalFundsCalc()
            self.updateAccountsTotalLabel(fromTotal: total)
            self.noDataImageSetup()
            self.tableView.reloadData()
        }
    }
    
    /// This function takes a double and updates the accountsTotal label
    func updateAccountsTotalLabel(fromTotal total: Double) {
        
        if total == 0.00 {
            self.accountsTotalLabel.text = "Let's start by adding your accounts!"
            self.accountsTotalLabel.textColor = .gray
            self.accountsTotalLabel.textAlignment = .center
            self.accountsTotalLabel.font = self.accountsTotalLabel.font.withSize(18)
            self.availableBalanceLabel.isHidden = true
            self.transferFundsButton.isHidden = true
            self.payDayButton.isHidden = true
        } else if total > 0.00 {
            self.accountsTotalLabel.text = "\(formatNumberToString(fromDouble: total))"
            self.accountsTotalLabel.textColor = .darkGreen
            self.accountsTotalLabel.textAlignment = .center
            self.accountsTotalLabel.font = self.accountsTotalLabel.font.withSize(25)
            self.availableBalanceLabel.isHidden = false
            self.transferFundsButton.isHidden = false
            self.payDayButton.isHidden = false
        } else if total < 0.00 {
            self.accountsTotalLabel.text = "\(formatNumberToString(fromDouble: total))"
            self.accountsTotalLabel.textColor = .darkRed
            self.accountsTotalLabel.textAlignment = .center
            self.accountsTotalLabel.font = self.accountsTotalLabel.font.withSize(25)
            self.availableBalanceLabel.isHidden = false
            self.transferFundsButton.isHidden = false
            self.payDayButton.isHidden = false
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
        
        return allAccounts.compactMap({ $0 })
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let titleSectionHeader = self.tableView(self.tableView, titleForHeaderInSection: section) else { return nil }
        return setUpTableViewHeader(withTableView: tableView, withSection: section, withSectionHeaderTitle: titleSectionHeader)
    }
        
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
        cell.textLabel?.text = account.name.lowercased().capitalized
        
        let stringAmount = formatNumberToString(fromDouble: account.total)
        cell.detailTextLabel?.text = stringAmount
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let alertController = UIAlertController(title: "Delete Account", message: "Please confirm that you want to delete this account. Deleting this account will delete all corresponding transactions and planned expenses. Deleting this account cannot be undone.", preferredStyle: .alert)
            
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
    
    
    // MARK: - Actions
    @IBAction func transferButtonFundsTapped(_ sender: UIButton) {
        resetTransferMoneyVariables()
        transferMoneyView.isHidden = false
        incomeDetailView.isHidden = true
    }
    
    @IBAction func payDayButtonTapped(_ sender: UIButton) {
        resetTransferMoneyVariables()
        incomeDetailView.isHidden = false
        transferMoneyView.isHidden = true
    }
    
    @IBAction func incomeDetailsCancelButtonTapped(_ sender: UIButton) {
        resetIncomeDetailView()
        resetTransferMoneyVariables()
    }
    
    @IBAction func transferMoneyCancelButtonTapped(_ sender: UIButton) {
        resetTransferMoneyView()
        resetTransferMoneyVariables()
    }
    
    @IBAction func depostiButtonTapped(_ sender: UIButton) {
        guard let amountString = payDayAmountTextField.text, amountString != "",
            let amount = Double(amountString),
            let account = payDayAccount else {return}
        
        account.total += amount
        setUpUI()
        tableView.reloadData()
        AccountController.shared.updateAccountWith(name: account.name, type: account.accountType, total: account.total, account: account) { (_) in
            // Nothing to do.
        }
        resetIncomeDetailView()
        resetTransferMoneyVariables()
    }
    
    @IBAction func transferButtonTapped(_ sender: UIButton) {
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
        resetTransferMoneyVariables()
    }
    
    // MARK: Button Functions
    func resetIncomeDetailView() {
        incomeDetailView.isHidden = true
        payDayAmountTextField.text = ""
    }
    
    func resetTransferMoneyView() {
        transferMoneyView.isHidden = true
        transferAmountTextField.text = ""
    }
    
    func resetTransferMoneyVariables() {
        fromAccountTxtField.text = ""
        toAccountTxtField.text = ""
        paydayAccountTextField.text = ""
        payDayAccount = nil
        fromAccount = nil
        toAccount = nil
    }
    
    // MARK: - Methods
    
    func updateTotalLabel() {
        let total = totalFundsCalc()
        accountsTotalLabel.text = formatNumberToString(fromDouble: total)
    }
    
    func addTapGesture() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(recognizer:)))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    func setUpDelegates() {
        tableView.dataSource = self
        tableView.delegate = self
        transferAmountTextField.delegate = self
        payDayAmountTextField.delegate = self
        accountPickerView.dataSource = self
        accountPickerView.delegate = self
        toAccountTxtField.delegate = self
        fromAccountTxtField.delegate = self
        
    }
    
    func checkIfUserIsSignedIntoCloudKit() {
        let cloudKitManager = CloudKitManager()
        if cloudKitManager.checkIfUserIsSignedIntoCloudKit() == false {
            presentSimpleAlert(controllerToPresentAlert: self, title: "Warning!", message: "You are either not signed into iCloud or you are out of iCloud space, which means your data will not be saved!")
        }
    }
    
    func roundButtons() {
        transferFundsButton.layer.cornerRadius = transferFundsButton.frame.height/4
        payDayButton.layer.cornerRadius = payDayButton.frame.height/4
        incomeDetailCancelButton.layer.cornerRadius = incomeDetailCancelButton.frame.height/4
        depositButton.layer.cornerRadius = depositButton.frame.height/4
        transferButton.layer.cornerRadius = transferButton.frame.height/4
        transferViewCancelButton.layer.cornerRadius = transferViewCancelButton.frame.height/4
    }
    
    func createPlusButton() {
        let button = UIButton()
        button.clipsToBounds = true
        button.setImage(#imageLiteral(resourceName: "plusButton"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(segueToDetailVC), for: UIControlEvents.touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func createQuestionMarkButton() {
        let button = UIButton()
        button.clipsToBounds = true
        button.setImage(#imageLiteral(resourceName: "questionMark"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(segueToInstructionVC), for: UIControlEvents.touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    // MARK: - Objective C Methods
    @objc func doneAccountPicker() {
        let account = AccountController.shared.accounts[accountPickerView.selectedRow(inComponent: 0)]
        
        switch textFieldBeingEdited {
        case paydayAccountTextField:
            paydayAccountTextField.text = account.name
            payDayAccount = account
        case fromAccountTxtField:
            fromAccountTxtField.text = account.name
            fromAccount = account
        default:
            toAccountTxtField.text = account.name
            toAccount = account
        }
        payDayAccount = account
        self.view.endEditing(true)
    }
    
    @objc func segueToInstructionVC() {
        self.performSegue(withIdentifier: "toInstructionVC", sender: self)
    }
    
    @objc func segueToDetailVC() {
        self.performSegue(withIdentifier: "toAccountDetail", sender: self)
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
                plannedExpense.monthlyTotals.append(plannedExpense.totalDeposited + plannedExpense.initialAmount)
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
                    plannedExpense.monthlyTotals.append(plannedExpense.totalDeposited + plannedExpense.initialAmount)
                } else {
                    plannedExpense.monthlyTotals.append(plannedExpense.totalDeposited + plannedExpense.initialAmount)
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
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toAccountDetail" {
            
            guard let destinationVC = segue.destination as? AccountDetailsViewController, let indexPath = tableView.indexPathForSelectedRow else {return}
            
            destinationVC.account = self.returnAllAccounts()[indexPath.section][indexPath.row]
            
        }
    }
}


// MARK: - Picker View Delegate and DataSource
extension AccountListViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
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
        
        switch textFieldBeingEdited {
        case paydayAccountTextField:
            let index = pickerView.selectedRow(inComponent: component)
            let account =  AccountController.shared.accounts[index]
            paydayAccountTextField.text = account.name
            payDayAccount = account
        case toAccountTxtField:
            let index = pickerView.selectedRow(inComponent: component)
            let account =  AccountController.shared.accounts[index]
            toAccountTxtField.text = account.name
            toAccount = account
        default:
            let index = pickerView.selectedRow(inComponent: component)
            let account =  AccountController.shared.accounts[index]
            fromAccountTxtField.text = account.name
            fromAccount = account
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pickerLabel = UILabel()
        let accounts = AccountController.shared.accounts
        let account = accounts[row]
        var size: CGFloat = 14.0
        
        switch pickerView {
        case accountPickerView:
            size = 18
            pickerLabel.textAlignment = .center
        default:
            pickerLabel.textAlignment = .left
        }
        
        pickerLabel.font = UIFont(name: "Avenir Next", size: size)
        pickerLabel.text = account.name
        
        return pickerLabel
    }
}


extension AccountListViewController: UITextFieldDelegate {
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
    
    @objc func dismissKeyboard(recognizer: UITapGestureRecognizer) {
        if depositButton.point(inside: recognizer.location(in: depositButton), with: nil) {
            depositButton.sendActions(for: .touchUpInside)
        }
        
        if transferButton.point(inside: recognizer.location(in: transferButton), with: nil) {
            transferButton.sendActions(for: .touchUpInside)
        }
        
        if incomeDetailCancelButton.point(inside: recognizer.location(in: incomeDetailCancelButton), with: nil) {
            incomeDetailCancelButton.sendActions(for: .touchUpInside)
        }
        
        if transferViewCancelButton.point(inside: recognizer.location(in: transferViewCancelButton), with: nil) {
            transferViewCancelButton.sendActions(for: .touchUpInside)
        }
        
        view.endEditing(true)
    }
    
    @objc func stopEditingTextField() {
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textFieldBeingEdited = textField
        
        switch textField {
        case paydayAccountTextField:
            showAccountPickerfor(txtfield: paydayAccountTextField)
        case toAccountTxtField:
            showAccountPickerfor(txtfield: toAccountTxtField)
        default:
            showAccountPickerfor(txtfield: fromAccountTxtField)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
