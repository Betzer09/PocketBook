//
//  Theme.swift
//  PocketBook
//
//  Created by Michael Meyers on 11/13/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation
import UIKit

var colors: [UIColor] = [
    // Make Colors Array longer
    .red,
    .orange,
    .yellow,
    .limeGreen,
    .green,
    .darkGreen,
    .cyan,
    .skyBlue,
    .blue,
    .navy,
    .indigo,
    .purple,
    .magenta,
    .salmon,
    .hotPink,
    .maroon
]

extension UIColor {
    static var darkGreen: UIColor {
        return UIColor(red: 65.0/255.0, green: 117.0/255.0, blue: 5.0/255.0, alpha: 1.0)
    }
    
    static var navy: UIColor {
        return UIColor(red: 19.0/255.0, green: 21.0/255.0, blue: 128.0/255.0, alpha: 1.0)
    }
    
    static var limeGreen: UIColor {
        return UIColor(red: 196.0/255.0, green: 255.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    }
    
    static var indigo: UIColor {
        return UIColor(red: 90.0/255.0, green: 7.0/255.0, blue: 167.0/255.0, alpha: 1.0)
    }
    
    static var maroon: UIColor {
        return UIColor(red: 147.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    }
    
    static var salmon: UIColor {
        return UIColor(red: 232.0/255.0, green: 108.0/255.0, blue: 108.0/255.0, alpha: 1.0)
    }
    
    static var skyBlue: UIColor {
        return UIColor(red: 142.0/255.0, green: 181.0/255.0, blue: 225.0/255.0, alpha: 1.0)
    }
    
    static var hotPink: UIColor {
        return UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 126.0/255.0, alpha: 1.0)
    }
}


