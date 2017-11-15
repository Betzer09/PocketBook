//
//  AccountDetailsViewController.swift
//  PocketBook
//
//  Created by Laura O'Brien on 11/6/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//


//NOTE: Text field heights and Account picker height are not adjusted for iPad v. iPhone aspects. All other label font sizes will adjust appropriately.


//NOTE: save button to OverviewVC segue is called "saveAccountChangeSegue"
//NOTE: cancel button to OverviewVC segue is called "cancelAccountChangeSegue"


// fix me

import UIKit

class AccountDetailsViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var totalTextField: UITextField!
    @IBOutlet weak var accountTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var transferFundsButton: UIButton!
    
    // MARK: - Properites
    
    var account: Account? {
        didSet{
            view.setNeedsDisplay()
        }
    }
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    //MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        checkSave()
    }
    
    
    @IBAction func transferFundsButton(_ sender: UIButton) {
        presentTransferAlert()
    }
    
    
    // MARK: - Methods
    func setUpUI() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dissmissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Check to see if there is an account
        guard let account = account else {return}
        
        // If there is an account update the views
        nameTextField.text = account.name
        var totalString = String(format: "%.2f", account.total)
        totalString.insert("$", at: totalString.startIndex)
        totalTextField.text = totalString
        accountTypeSegmentedControl.selectedSegmentIndex = updateAccountTypeSegment()
    }
    
    @objc func dissmissKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func reloadTableView() {
        DispatchQueue.main.async {
            self.view.setNeedsDisplay()
        }
    }
    
    private func checkSave() {
        let accountType = checkToSeeWhichSegmentIsPressed()
        
        // If there is an account update it
        if account != nil {
            guard let name = nameTextField.text, let account = account, !name.isEmpty else {
                presentSimpleAlert(controllerToPresentAlert: self, title: "Error", message: "You need to give your account a name.")
                return
            }
            
            if let stringTotal = totalTextField.text?.dropFirst() {
                
                guard let total = Double(stringTotal) else {
                    presentSimpleAlert(controllerToPresentAlert: self, title: "Error", message: "You have entered an invalid total.")
                    return
                }
                
                AccountController.shared.updateAccountWith(name: name, type: accountType, total: total, account: account, completion: { (_) in
                    // TODO: Maybe change this in the AccountController                    
                })
            }

        } else {
            // If there isn't an account save it
            guard let name = nameTextField.text, !name.isEmpty else {
                
                // Alert the user that they must put something in the fields
                presentSimpleAlert(controllerToPresentAlert: self, title: "Make sure to fill all fields!", message: "")
                return
            }
            
            if let stringTotal = totalTextField.text?.dropFirst() {
                guard let total = Double(stringTotal) else {
                    presentSimpleAlert(controllerToPresentAlert: self, title: "Error", message: "You have entered an invalid total.")
                    return
                }
                
                AccountController.shared.createAccount(name: name, type: accountType, total: total, completion: nil)
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    private func checkToSeeWhichSegmentIsPressed() -> String {
        
        if accountTypeSegmentedControl.selectedSegmentIndex == 0 {
            return "Checking"
        } else if accountTypeSegmentedControl.selectedSegmentIndex == 1 {
            return "Savings"
        } else {
            // This is a credit account
            return "Credit"
        }
        
    }
    
    private func updateAccountTypeSegment() -> Int {
        if account?.accountType == "Checking" {
            return 0
        } else if account?.accountType == "Savings" {
            return 1
        } else {
            return 2
        }
    }
    
    // MARK: - Alert Controller
    func presentTransferAlert() {
        guard let accountVC = self.account else {return}
        let name = accountVC.name
        var amountTextField = UITextField()
        let alertController = UIAlertController(title: "Transfer Funds", message: "From: \(name) \nTo:", preferredStyle: .alert)
        
        alertController.addTextField { (textfield) in
            textfield.placeholder = "Enter Amount to Transfer"
            // Add logic so they can only add nubmers
            amountTextField = textfield
        }
        
        var accounts = AccountController.shared.accounts
        var count = 0
        for account in accounts {
            if account.name == name {
                accounts.remove(at: count)
            }
            count += 1
        }
        for account in accounts {
            let action = UIAlertAction(title: account.name, style: .default, handler: { (_) in
                guard let amountString = (amountTextField.text), amountString != "",
                    let amount = Double(amountString) else {return}
                accountVC.total -= amount
                AccountController.shared.updateAccountWith(name: name, type: accountVC.accountType, total: accountVC.total, account: accountVC, completion: { (account) in
                    //NOTHING
                })
                self.setUpUI()
                
                account.total += amount
                print("\(name) has \(accountVC.total)")
                print("\(account.name) has \(account.total)")
                print("\(self.account?.total)")
            })
            alertController.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}
















