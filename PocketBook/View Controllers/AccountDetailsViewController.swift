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
    // MARK: - Properites
    
    var account: Account?
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    //MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        checkSave()
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
    
    private func checkSave() {
        let accountType = checkToSeeWhichSegmentIsPressed()
        
        // If there is an account update it
        if account != nil {
            guard let name = nameTextField.text, let account = account, !name.isEmpty else {
                presentSimpleAlert(title: "Error", message: "You need to give your account a name.")
                return
            }
            
            if let stringTotal = totalTextField.text?.dropFirst() {
                
                guard let total = Double(stringTotal) else {
                    self.presentSimpleAlert(title: "Error", message: "You have entered an invalid total.")
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
                self.presentSimpleAlert(title: "Make sure to fill all fields!", message: "")
                return
            }
            
            if let stringTotal = totalTextField.text?.dropFirst() {
                guard let total = Double(stringTotal) else {
                    self.presentSimpleAlert(title: "Error", message: "You have entered an invalid total.")
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
    
    private func presentSimpleAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(dismissAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
















