//
//  TransactionsDetailViewController.swift
//  PocketBook
//
//  Created by Laura O'Brien on 11/6/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class TransactionsDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: - Outlets
    @IBOutlet weak var accountPicker: UIPickerView!
    
    // MARK: - Properties
    
    
    // MARK: - View LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setPickerDelegates()
        setUpUI()

    }
    
    // MARK: - Account Picker Functions
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

    
    func setUpUI() {
        accountPicker.isHidden = true
    }
    
    func setPickerDelegates() {
        accountPicker.dataSource = self
        accountPicker.delegate = self
    }
    
    // MARK: - Save Transactions
    func saveTransaction() {
        
    }


}
