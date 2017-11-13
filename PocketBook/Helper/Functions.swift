//
//  Functions.swift
//  PocketBook
//
//  Created by Michael Meyers on 11/13/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation
import UIKit

let view = UIView()

func presentSimpleAlert(controllerToPresentAlert vc: UIViewController, title: String, message: String) {
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    
    alert.addAction(dismissAction)
    
    vc.present(alert, animated: true, completion: nil)
}

