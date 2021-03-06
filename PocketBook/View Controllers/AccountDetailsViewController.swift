//
//  AccountDetailsViewController.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/7/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//


//NOTE: save button to OverviewVC segue is called "saveAccountChangeSegue"
//NOTE: cancel button to OverviewVC segue is called "cancelAccountChangeSegue"


import UIKit

class AccountDetailsViewController: UIViewController, UIGestureRecognizerDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var transferMoneyView: UIView!
    @IBOutlet weak var fromAccountLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var totalTextField: UITextField!
    @IBOutlet weak var transferAmountTextField: UITextField!
    @IBOutlet weak var accountTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var transferFundsButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var transferButton: UIButton!
    @IBOutlet weak var toAccountTxtField: UITextField!
    
    // MARK: - Customize Segmented Control
    func customizeSegmentedControl() {
        accountTypeSegmentedControl.customizeSegmentedControl()

    }
    
    // MARK: - Properites
    var account: Account? {
        didSet{
            view.setNeedsDisplay()
        }
    }
    var toAccount: Account? {
        didSet {
            transferButton.isEnabled = true
        }
    }
    
    
    var currentYShiftForKeyboard: CGFloat = 0
    var textFieldBeingEdited: UITextField?
    let toAccountPickerView = UIPickerView()
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeSegmentedControl()
        setupUI()
        setDelegates()
        addTapGesture()
        addNotificationObservers()
        setupGestureRecongnizer()
    }
    
    //MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        checkSave()
    }
    
    @IBAction func transferFundsButton(_ sender: UIButton) {
        transferMoneyView.isHidden = false
        transferFundsButton.isHidden = true
        guard let account = account else {return}
        fromAccountLabel.text = account.name
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        resetTransferMoneyView()
        transferFundsButton.isHidden = false
    }
    
    @IBAction func transferButtonTapped(_ sender: UIButton) {
        // TODO: ADDED SIMPLE ARE YOU SURE ALERT
        guard let amountString = transferAmountTextField.text, amountString != "",
            let amount = Double(amountString),
            let toAccount = toAccount,
            let fromAccount = account else {
                return
        }
        
        fromAccount.total -= amount
        toAccount.total += amount
        AccountController.shared.updateAccountWith(name: toAccount.name, type: toAccount.accountType, total: toAccount.total, account: toAccount, completion:  { (_) in
            // TODO: DELETE THIS CLOSURE
        })
        AccountController.shared.updateAccountWith(name: fromAccount.name, type: fromAccount.accountType, total: fromAccount.total, account: fromAccount, completion: { (_) in
            // TODO: DELETE THIS CLOSURE
        })
        resetTransferMoneyView()
        totalTextField.text = formatNumberToString(fromDouble: fromAccount.total)
        view.setNeedsDisplay()
    }
    
    // MARK: Button Functions

    func resetTransferMoneyView() {
        transferFundsButton.isHidden = false
        transferMoneyView.isHidden = true
        transferAmountTextField.text = ""
    }
    
    // MARK: - Methods
    func setupUI() {
        
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.tintColor = .white            
        }
        
        if let account = account {
            self.navigationItem.title = account.name
        } else {
            self.navigationItem.title = "New Account"
        }
        
        if account == nil {
            transferFundsButton.isHidden = true
            transferMoneyView.isHidden = true
        }
        // Check to see if there is an account
        guard let account = account else {return}
        
        // If there is an account update the views
        nameTextField.text = account.name
        let totalString = formatNumberToString(fromDouble: account.total)
        totalTextField.text = totalString
        accountTypeSegmentedControl.selectedSegmentIndex = updateAccountTypeSegment()
        
        transferMoneyView.isHidden = true
        roundButtons()
        
    }
    
    func setupGestureRecongnizer() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dissmissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func addTapGesture() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(recognizer:)))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    func setDelegates() {
        transferAmountTextField.delegate = self
        nameTextField.delegate = self
        toAccountPickerView.delegate = self
        toAccountPickerView.dataSource = self
    }
    
    func roundButtons() {
        transferFundsButton.layer.cornerRadius = transferFundsButton.frame.height/4
        cancelButton.layer.cornerRadius = cancelButton.frame.height/4
        transferButton.layer.cornerRadius = transferButton.frame.height/4
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
        let accountType = checkWhichControlIsPressed(segmentedControl: accountTypeSegmentedControl, type1: .checking, type2: .saving, type3: .credit)
        
        // If there is an account update it
        if account != nil {
            guard let name = nameTextField.text, let account = account, !name.isEmpty else {
                presentSimpleAlert(controllerToPresentAlert: self, title: "Error", message: "You need to give your account a name.")
                nameTextField.backgroundColor = UIColor.lightPink
                return
            }
            
            let total: String = removeCharactersFromTextField(totalTextField)
            guard let returnTotal = Double(total) else {
                presentSimpleAlert(controllerToPresentAlert: self, title: "Error", message: "You have entered an invalid total.")
                totalTextField.backgroundColor = UIColor.lightPink
                return
            }
            
            AccountController.shared.updateAccountWith(name: name, type: accountType, total: returnTotal, account: account, completion: { (_) in
                // TODO: Maybe change this in the AccountController
            })
            
        } else {
            // If there isn't an account save it
            guard let name = nameTextField.text, !name.isEmpty else {
                
                // Alert the user that they must put something in the fields
                presentSimpleAlert(controllerToPresentAlert: self, title: "Error", message: "Make sure to fill all fields!")
                nameTextField.backgroundColor = UIColor.lightPink
                return
                
            }
            
            if let stringTotal = totalTextField.text {
                guard let total = Double(stringTotal) else {
                    presentSimpleAlert(controllerToPresentAlert: self, title: "Error", message: "You have entered an invalid total.")
                    totalTextField.backgroundColor = UIColor.lightPink
                    return
                }
                
                // Check to see if the user is duplicating budget item name
                for account in AccountController.shared.accounts {
                    if account.name.lowercased() == nameTextField.text?.lowercased() {
                        presentSimpleAlert(controllerToPresentAlert: self, title: "Duplicate Account", message: "That account already exists. Please enter another account with a different name.")
                        return
                    }
                }
                
                AccountController.shared.createAccount(name: name, type: accountType, total: total, completion: nil)
            }
        }
        navigationController?.popViewController(animated: true)
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
}


// MARK: - Picker View Delegate and DataSource
extension AccountDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
        let index = pickerView.selectedRow(inComponent: component)
        let account =  AccountController.shared.accounts[index]
        toAccount = account
    }
    
    
    func showAccountPickerfor(txtfield: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAccountPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dissmissKeyboard))
        
        toolbar.setItems([cancelButton, spaceButton,doneButton], animated: false)
        txtfield.inputAccessoryView = toolbar
        txtfield.inputView = toAccountPickerView
        
    }
    
    @objc func doneAccountPicker() {
        let account = AccountController.shared.accounts[toAccountPickerView.selectedRow(inComponent: 0)]
        toAccountTxtField.text = account.name
        self.toAccount = account
        view.endEditing(true)
    }
}


// MARK: - TextField Delegate
extension AccountDetailsViewController: UITextFieldDelegate {
    
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
    
    /// Used in case someones presses in the view
    @objc func dismissKeyboard(recognizer: UITapGestureRecognizer) {

        if transferButton.point(inside: recognizer.location(in: transferButton), with: nil) {
            transferButton.sendActions(for: .touchUpInside)
        }

        if cancelButton.point(inside: recognizer.location(in: cancelButton), with: nil) {
            cancelButton.sendActions(for: .touchUpInside)
        }

        view.endEditing(true)
    }
    
    func stopEditingTextField() {
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldBeingEdited = textField
        
        if textField == toAccountTxtField {
            showAccountPickerfor(txtfield: textField)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return false
    }
    
}
