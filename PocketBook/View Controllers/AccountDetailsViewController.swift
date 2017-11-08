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



import UIKit

class AccountDetailsViewController: UIViewController {
    
    // MARK: - Properites
    var account: Account? // This is where the Segue from the overviewViewController will pass its information

    //MARK: - Outlets
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var typePickerView: UIPickerView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
    // We shoudn't need an outlet for the lables
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalTextField: UITextField!
    
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
    }

    //MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        checkSave()
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
    }
    
    // MARK: - Methods
    func updateViews() {
        // Check to see if there is an account
        guard let account = account else {return}
        
        // If there is an account update the views
        nameTextField.text = account.name
        totalTextField.text = "\(account.total)"
    }
    
    func checkSave() {
        
        // If there is an account update it
        if account != nil {
            guard let name = nameTextField.text,
            let total = totalTextField.text,
            let account = account else {return}
            
            AccountController.shared.updateAccountWith(name: name, type: typePickerView.description, total: Double(total)!, account: account, completion: { (_) in
                // TODO: Maybe change this in the AccountController
                
                // Might need to add another notification to update the tableView
            })
            
        } else {
            // If there isn't an account save it
            guard let name = nameTextField.text,
                let total = totalTextField.text, !name.isEmpty, !total.isEmpty else {
                   // Alert the user that they must put something in the fields
                    return
            }
            
            AccountController.shared.createAccount(name: name, type: typePickerView.description, total: Double(total)!, completion: nil)
            
        }
    }

}
















