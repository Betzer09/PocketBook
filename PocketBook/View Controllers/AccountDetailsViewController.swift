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
    
    // MARK: - Properites
    var account: Account? // This is where the Segue from the overviewViewController will pass its information
    
    //MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var totalTextField: UITextField!
    @IBOutlet weak var accountTypeSegmentedControl: UISegmentedControl!
    
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
    }

    //MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        checkSave()
    }

    
    // MARK: - Methods
    func updateViews() {
        // Check to see if there is an account
        guard let account = account else {return}
        
        // If there is an account update the views
        nameTextField.text = account.name
        totalTextField.text = "\(account.total)"
    }
    
    private func checkSave() {
        
        // If there is an account update it
        if account != nil {
            guard let name = nameTextField.text,
            let total = totalTextField.text,
            let account = account else {return}
            let accountType = checkToSeeWhichSegmentIsPressed()
            
            AccountController.shared.updateAccountWith(name: name, type: accountType, total: Double(total)!, account: account, completion: { (_) in
                // TODO: Maybe change this in the AccountController
                
                // Might need to add another notification to update the tableView
            })
            
        } else {
            // If there isn't an account save it
            guard let name = nameTextField.text,
                let total = totalTextField.text, !name.isEmpty, !total.isEmpty else {
                   // Alert the user that they must put something in the fields
                    presentSimpleAlert(title: "Make sure to fill all fields!", message: "Got it")
                    return
            }
            let accountType = checkToSeeWhichSegmentIsPressed()
            
            let totalDouble = Double(total)!
            AccountController.shared.createAccount(name: name, type: accountType, total: totalDouble, completion: nil)
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
    
    private func presentSimpleAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(dismissAction)
        
        self.present(alert, animated: true, completion: nil)
    }

}
















