//
//  KeyBoardFunctions.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/15/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

@objc protocol ShiftableViewController {
    
    @objc func keyboardWillShow(notification: Notification)
    @objc func keyboardWillHide(notification: Notification)
    
    func yShiftWhenKeyboardAppearsFor(textField: UITextField, keyboardHeight: CGFloat, nextY: CGFloat) -> CGFloat
    func stopEditingTextField()
    
    var currentYShiftForKeyboard: CGFloat { get set }
    
    var textFieldBeingEdited: UITextField? { get set }
    var view: UIView! { get }
}
