//
//  UserNotificationHelper.swift
//  PocketBook
//
//  Created by Austin Betzer on 10/2/18.
//  Copyright © 2018 SPARQ. All rights reserved.
//

import Foundation
import UserNotifications
import CloudKit
import UIKit


class UserNotificationHelper: NSObject {
    private override init() {}
    
    static let shared = UserNotificationHelper()
    let unCenter = UNUserNotificationCenter.current()
    let privateDBContainer = CKContainer.default().privateCloudDatabase
    
    enum CloudSubscriptions: String {
        case account = "Account"
        case transaciton = "Transaction"
        case plannedExpense = "PlannedExpense"
        case budgetItem = "BudgetItem"
        case user = "User"
    }
    
    let cloudSunscriptions: [String] = [
        Keys.recordAccountType, Keys.recordTransactionType,
        Keys.recordPlannedExpenseType, Keys.recordBudgetItemType, Keys.recordUserType
    ]
    
    func authorizeNotification() {
        let options : UNAuthorizationOptions = [.sound, .badge, .alert]
        unCenter.requestAuthorization(options: options) { (authorized, error) in
            NSLog(error?.localizedDescription ?? "No Error")
            
            guard authorized else {return}
            DispatchQueue.main.async {
                self.configureNotifiaction()
                self.startDailyReminderNotification()
            }
            
        }
    }
    
    func configureNotifiaction() {
        unCenter.delegate = self
        
        let application = UIApplication.shared
        application.registerForRemoteNotifications()
        
        unCenter.getNotificationSettings { (settings) in
            let value = UserDefaults.standard.object(forKey: Keys.notificationKey)
            if settings.alertSetting == .enabled && value == nil {
                UserDefaults.standard.set(true, forKey: Keys.notificationKey)
                self.registerForNotifcations()
                self.startDailyReminderNotification()
            }
        }
        
    }

    
    func registerForNotifcations() {
        
        for subscription in cloudSunscriptions {
            self.registerForSubscriptionWith(documentKey: subscription)
        }
    }
    
    func removeNotificationsSubsriptions() {
        for subscription in cloudSunscriptions {
            privateDBContainer.delete(withSubscriptionID: subscription) { (responce, error ) in
                guard let error = error else {return}
                NSLog("Error removing subscription :\(error)")
            }
        }
    }
    
    func registerForSubscriptionWith(documentKey key: String) {
        let subscription = CKQuerySubscription(recordType: key, predicate: NSPredicate(value: true), options: [.firesOnRecordUpdate, .firesOnRecordCreation, .firesOnRecordDeletion])
        
        
        let info = CKNotificationInfo()
        
        switch key {
        case Keys.recordAccountType:
            info.category = CloudSubscriptions.account.rawValue
        case Keys.recordTransactionType:
            info.category = CloudSubscriptions.transaciton.rawValue
        case Keys.recordBudgetItemType:
            info.category = CloudSubscriptions.budgetItem.rawValue
        case Keys.recordPlannedExpenseType:
            info.category = CloudSubscriptions.plannedExpense.rawValue
        default:
            info.category = CloudSubscriptions.user.rawValue
        }
        
        info.soundName = "default"
        info.shouldBadge = false
        subscription.notificationInfo = info
        
        
        privateDBContainer.save(subscription) { (savedSubscription, error) in
            if let error = error {
                NSLog(error.localizedDescription)
            }
            
            guard let savedSubscription = savedSubscription else {return}
            // save the subscription id?
            print("\(savedSubscription.subscriptionID)")
            
        }
        
    }
}

extension UserNotificationHelper: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        removeOldNotifications()
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let subscirptionIdentifer = notification.request.content.categoryIdentifier
        
        switch subscirptionIdentifer {
        case CloudSubscriptions.account.rawValue:
            AccountController.shared.fetchAccountsFromCloudKit()
        case CloudSubscriptions.transaciton.rawValue:
            TransactionController.shared.fetchTransActionsFromCloudKit()
        case CloudSubscriptions.budgetItem.rawValue:
            BudgetItemController.shared.fetchBugetItemFromCloudKit()
        case CloudSubscriptions.plannedExpense.rawValue:
            PlannedExpenseController.shared.fetchPlannedExpensesFromCloudKit()
        case CloudSubscriptions.user.rawValue:
            UserController.shared.fetchUserFromCloudKit()
        default:
            // Daily notificaiton
            print("this is the daily notification..")
        }
        
        completionHandler([])
    }
    
    
    func removeOldNotifications() {
        
        var count: Int = 0
        unCenter.getDeliveredNotifications { (notifications) in
            count = notifications.count
        }
        
        DispatchQueue.main.async {
            self.unCenter.removeAllDeliveredNotifications()
            print(count)
            UIApplication.shared.applicationIconBadgeNumber = 0
            
        }
    }
    
    func startDailyReminderNotification() {
        var dateComponents = DateComponents()
        dateComponents.hour = 00
        dateComponents.minute = 40
        
        let notification = UNMutableNotificationContent()
        notification.sound = UNNotificationSound.default()
        notification.title = "Daily Reminder"
        notification.body = "Don't forget to add your transactions for the day!"
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_reminder", content: notification, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func registerForNotification() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: Keys.notificationKey)
    }
}
