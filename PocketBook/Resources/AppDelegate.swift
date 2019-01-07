//
//  AppDelegate.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/7/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        AccountController.shared.fetchAccountsFromCloudKit()
        BudgetItemController.shared.fetchBugetItemFromCloudKit()
        TransactionController.shared.fetchTransActionsFromCloudKit()
        PlannedExpenseController.shared.fetchPlannedExpensesFromCloudKit()
        UserController.shared.fetchUserFromCloudKit()
        
        
        
        UserDefaults.standard.register(defaults: ["onboarding" : false])
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let onboardingStoryboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let mainStoryboard = UIStoryboard(name: "OverviewTabBar", bundle: nil)
        var viewController: UIViewController

        if (UserDefaults.standard.bool(forKey: "onboarding")) == false {
            // Show onboarding screen and update UserDefaults
            UserDefaults.standard.set(true, forKey: "onboarding")
            UserDefaults.standard.synchronize()
            viewController = onboardingStoryboard.instantiateViewController(withIdentifier: "Onboarding")
        } else {
            // Show main screen
            viewController = mainStoryboard.instantiateInitialViewController()!
        }
        self.window?.rootViewController = viewController
        self.window?.makeKeyAndVisible()
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 4.0/255.0, green: 45.0/255.0, blue: 75.0/255.0, alpha: 1.0)
        
        guard let font2 = UIFont(name: "Avenir Next", size: 14) else {return false}
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: font2], for: .normal)
        application.registerForRemoteNotifications()
        return true
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Received Notification")
        
        
        AccountController.shared.fetchAccountsFromCloudKit()
        PlannedExpenseController.shared.fetchPlannedExpensesFromCloudKit()
        TransactionController.shared.fetchTransActionsFromCloudKit()
        UserController.shared.fetchUserFromCloudKit()
        BudgetItemController.shared.fetchBugetItemFromCloudKit()
        
        
        
        completionHandler(.newData)
    }
}

