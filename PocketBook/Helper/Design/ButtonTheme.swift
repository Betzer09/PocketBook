//
//  RoundedButton.swift
//  PocketBook
//
//  Created by Austin Betzer on 2/9/19.
//  Copyright © 2019 SPARQ. All rights reserved.
//

import UIKit

class ButtonTheme: UIButton {

    override func setNeedsLayout() {
        self.layer.cornerRadius = self.frame.height / 4
        self.titleLabel?.adjustsFontSizeToFitWidth = true
    }
}

