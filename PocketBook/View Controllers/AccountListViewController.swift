//
//  AccountListViewController.swift
//  PocketBook
//
//  Created by Michael Meyers on 11/15/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class AccountListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Properties
    let arrayString: [String] = [
        "Checking",
        "Savings",
        "Credit Card"
    ]
    
    var toAccount: Account?
    var fromAccount: Account?
    var payDayAccount: Account?
    
    // MARK: - Outlets
    @IBOutlet weak var toPickerView: UIPickerView!
    @IBOutlet weak var fromPickerView: UIPickerView!
    @IBOutlet weak var payDayPickerView: UIPickerView!
    @IBOutlet weak var transferFundsButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var transferAmountTextField: UITextField!
    @IBOutlet weak var payDayAmountTextField: UITextField!
    @IBOutlet var transferViews: [UIView]!
    @IBOutlet var payDayViews: [UIView]!
    @IBOutlet weak var payDayButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View LifeCyles
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: Notifications.accountWasUpdatedNotification, object: nil)
        
        setUpUI()
        
        let cloudKitManager = CloudKitManager()
        if cloudKitManager.checkIfUserIsSignedIntoCloudKit() == false {
            presentSimpleAlert(controllerToPresentAlert: self, title: "Warning!", message: "You are not signed into iCloud, which means your data will not be saved! Go into settings and turn on iCloud.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.fromPickerView.reloadAllComponents()
            self.toPickerView.reloadAllComponents()
            self.payDayPickerView.reloadAllComponents()
            self.fromPickerView.reloadInputViews()
            self.toPickerView.reloadInputViews()
            self.payDayPickerView.reloadInputViews()
        }
        setUpTransferFundsView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Setup View
    func setUpTransferFundsView( ) {
        transferFundsButton.isHidden = false
        payDayButton.isHidden = false
        cancelButton.isHidden = true
        transferViews.forEach { $0.isHidden = true }
        payDayViews.forEach({ $0.isHidden = true })
    }
    
    @objc func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Setup TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AccountController.shared.accounts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath)
        
        let account = AccountController.shared.accounts[indexPath.row]
        cell.textLabel?.text = account.name
        
        let stringAmount = String(format: "$%.2f", account.total)
        cell.detailTextLabel?.text = stringAmount
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            let account = AccountController.shared.accounts[indexPath.row]
            AccountController.shared.accounts.remove(at: indexPath.row)
            AccountController.shared.delete(account: account)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
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
            // FIXME: Present alert for the user to make sure that they want to delete an account
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
        if pickerView == toPickerView {
            let index = pickerView.selectedRow(inComponent: 0)
            let account =  AccountController.shared.accounts[index]
            toAccount = account
        }
        if pickerView == fromPickerView {
            let index = pickerView.selectedRow(inComponent: 0)
            let account =  AccountController.shared.accounts[index]
            fromAccount = account
        }
        if pickerView == payDayPickerView {
            let index = pickerView.selectedRow(inComponent: 0)
            let account =  AccountController.shared.accounts[index]
            payDayAccount = account
        }
    }

    
    // MARK: - Actions
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        cancelButton.isHidden = true
        payDayButton.isHidden = false
        transferFundsButton.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.transferViews.reversed().forEach { $0.isHidden = true }
            self.payDayViews.reversed().forEach { $0.isHidden = true }
        }
    }
    
    @IBAction func transferButtonFundsTapped(_ sender: UIButton) {
        transferFundsButton.isHidden = true
        payDayButton.isHidden = true
        UIView.animate(withDuration: 0.3) {
            self.transferViews.forEach { $0.isHidden = false }
        }
        cancelButton.isHidden = false
    }
    
    @IBAction func payDayButtonTapped(_ sender: UIButton) {
        transferFundsButton.isHidden = true
        payDayButton.isHidden = true
        UIView.animate(withDuration: 0.3) {
            self.payDayViews.forEach { $0.isHidden = false }
        }
        cancelButton.isHidden = false
    }
    
    @IBAction func transferButtonTapped(_ sender: UIButton) {
        guard let amountString = transferAmountTextField.text, amountString != "",
            let amount = Double(amountString),
            let toAccount = toAccount,
            let fromAccount = fromAccount else {return}
        
        fromAccount.total -= amount
        toAccount.total += amount
        transferAmountTextField.text = ""
        tableView.reloadData()
        AccountController.shared.updateAccountWith(name: toAccount.name, type: toAccount.accountType, total: toAccount.total, account: toAccount, completion:  { (_) in
        // TODO: DELETE THIS CLOSURE
        })
        AccountController.shared.updateAccountWith(name: fromAccount.name, type: fromAccount.accountType, total: fromAccount.total, account: fromAccount, completion: { (_) in
        // TODO: DELETE THIS CLOSURE
        })
            
        UIView.animate(withDuration: 0.3) {
            self.transferViews.reversed().forEach { $0.isHidden = true }
        }
        cancelButton.isHidden = true
        transferFundsButton.isHidden = false
        payDayButton.isHidden = false
        // Add Simple Alert
    }
    
    @IBAction func payMeButtonTapped(_ sender: UIButton) {
        guard let amountString = payDayAmountTextField.text, amountString != "",
            let amount = Double(amountString),
            let account = payDayAccount else {return}
        
        account.total += amount
        payDayAmountTextField.text = ""
        tableView.reloadData()
        AccountController.shared.updateAccountWith(name: account.name, type: account.accountType, total: account.total, account: account) { (_) in
            // Nothing to do.
        }
        
        UIView.animate(withDuration: 0.3) {
            self.payDayViews.reversed().forEach { $0.isHidden = true }
        }
        cancelButton.isHidden = true
        transferFundsButton.isHidden = false
        payDayButton.isHidden = false
    }
    
    // MARK: - Methods
    func setUpUI() {
        toPickerView.delegate = self
        toPickerView.dataSource = self
        fromPickerView.dataSource = self
        fromPickerView.delegate = self
        payDayPickerView.dataSource = self
        payDayPickerView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toAccountDetail" {
            
            guard let destinationVC = segue.destination as? AccountDetailsViewController, let indexPath = tableView.indexPathForSelectedRow else {return}
            
            destinationVC.account = AccountController.shared.accounts[indexPath.row]
        }
    }
}
