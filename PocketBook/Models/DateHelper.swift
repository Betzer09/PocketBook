//
//  DateHelper.swift
//  PocketBook
//
//  Created by Laura O'Brien on 11/13/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation

enum DateHelper {
    
    static var currentDate: Date? {
        let calendar = Calendar.current
        let now = Date()
        return calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now)
    }
    
}
