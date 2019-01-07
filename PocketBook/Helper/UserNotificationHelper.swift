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
//        unCenter.delegate = self
        
        let application = UIApplication.shared
        application.registerForRemoteNotifications()
        
        unCenter.getNotificationSettings { (settings) in
            let value = UserDefaults.standard.object(forKey: Keys.notificationKey)
            if settings.alertSetting == .enabled && value == nil {
                UserDefaults.standard.set(true, forKey: Keys.notificationKey)
                self.startDailyReminderNotification()
            }
        }
        
    }

    // Makes it so if something changes in the cloud the user has updated information.
    
    let subscriptionKey = "HasSubscribedToSilentNotifications"
    func checkIfUserHasSubscribedForSilentNotifications() {
        let defaults = UserDefaults.standard
        let hasSubscribed = defaults.value(forKey: subscriptionKey) as? Bool
        
        if let hasSubscribed = hasSubscribed {
            if hasSubscribed == false {
                registerForNotifcationsSubscriptions()
            } else {
                return
            }
        } else {
            registerForNotifcationsSubscriptions()
        }
    }
    
    func registerForNotifcationsSubscriptions() {
        UserDefaults.standard .set(true, forKey: subscriptionKey)
        
        registerForSubscriptionWith(documentKey: CloudSubscriptions.account.rawValue) { (done) in
            guard done else {return}
            self.registerForSubscriptionWith(documentKey: CloudSubscriptions.transaciton.rawValue) { (done) in
                guard done else {return}
                self.registerForSubscriptionWith(documentKey: CloudSubscriptions.budgetItem.rawValue) { (done) in
                    guard done else {return}
                    self.registerForSubscriptionWith(documentKey: CloudSubscriptions.user.rawValue) { (done) in
                        guard done else {return}
                        self.registerForSubscriptionWith(documentKey: CloudSubscriptions.plannedExpense.rawValue) { (done) in
                            guard done else {return}
                            
                        }
                    }
                }
            }
        }
    }
    
    func registerForSubscriptionWith(documentKey key: String, completion: @escaping(_ success: Bool) -> Void) {
        let subscription = CKQuerySubscription(recordType: key, predicate: NSPredicate(value: true), options: [.firesOnRecordUpdate, .firesOnRecordCreation, .firesOnRecordDeletion])
        
        
        let info = CKNotificationInfo()
        info.shouldSendContentAvailable = true
        subscription.notificationInfo = info
        
        
        privateDBContainer.save(subscription) { (savedSubscription, error) in
            if let error = error {
                NSLog(error.localizedDescription)
                completion(false)
            }
            
            guard let savedSubscription = savedSubscription else {
                completion(false)
                return
            }
            // save the subscription id?
            print("\(savedSubscription.subscriptionID)")
            completion(true)
            
        }
        
    }
}

extension UserNotificationHelper {
    
    // TODO: - For verision 2.0
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
