//
//  Notifications.swift
//  PocketBook
//
//  Created by Michael Meyers on 11/9/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation

// MARK: - Notification for PageView ViewControllers

struct Notifications {
    
    static let viewControllerHasFinishedLoading = Notification.Name("viewControllerHasFinishedLoading")
    
    static let sendingTimeFrameInfoToVCs = Notification.Name("sendingTimeFrameInfoToVCs")
    
    static let accountWasUpdatedNotification = Notification.Name("accountWasUpdated")
    
    static let transactionWasUpdatedNotification = Notification.Name("transactionWasUpdated")
}


