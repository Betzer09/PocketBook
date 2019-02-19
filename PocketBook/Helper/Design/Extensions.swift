//
//  Extensions.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/7/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Customize Segmented Control
extension UISegmentedControl{
    func customizeSegmentedControl() {
        setBackgroundImage(imageWithColor(color: .lightGray), for: .selected, barMetrics: .default)
        setBackgroundImage(imageWithColor(color: .charcoal), for: .normal, barMetrics: .default)
        setDividerImage(imageWithColor(color: UIColor.clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        guard let avenirFont = UIFont(name: "Avenir Next", size: 12.0) else {NSLog("Coundn't find Avenir Next font: \(#file)"); return}

        let attr = NSDictionary(object: avenirFont, forKey: NSAttributedString.Key.font as NSCopying)
        UISegmentedControl.appearance().setTitleTextAttributes(attr as [NSObject : AnyObject] as [NSObject : AnyObject] as? [NSAttributedString.Key : Any] , for: .normal)
        
        let selected: NSDictionary = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: avenirFont
        ]
        
        let notSelected: NSDictionary = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: avenirFont
        ]

        setTitleTextAttributes(selected as [NSObject : AnyObject] as [NSObject : AnyObject] as? [NSAttributedString.Key : Any], for: .selected)
        setTitleTextAttributes(notSelected as [NSObject : AnyObject] as [NSObject : AnyObject] as? [NSAttributedString.Key : Any], for: .normal)

        
    }
    
    // Create a 1x1 image with this color
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width:  1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        layer.cornerRadius = 13
        layer.masksToBounds = true
        UIGraphicsEndImageContext()
        return image!
    }
}

extension String {
    
    /// Removes the white space from both the beginning and end of the string.
    func removeWhiteSpaces() -> String {
        return self.trimmingCharacters(in: .whitespaces)
    }
    
}
