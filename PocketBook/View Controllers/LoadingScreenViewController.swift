//
//  LoadingScreenViewController.swift
//  PocketBook
//
//  Created by Austin Betzer on 2/11/19.
//  Copyright © 2019 SPARQ. All rights reserved.
//

import UIKit

class LoadingScreenViewController: UIViewController {

    @IBOutlet weak var pocketbookView: UIImageView!
    @IBOutlet weak var lblGettingThingsReady: UILabel!
    var viewHasDisapperaed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pocketbookView.alpha = 0
        lblGettingThingsReady.alpha = 0
        animateImage()
        animateLabel()
        fetchInformation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewHasDisapperaed = true
    }
    
    func animateImage() {
        guard viewHasDisapperaed == false else {return}
        pocketbookView.transform = CGAffineTransform(rotationAngle: 3)
        
        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            self.pocketbookView.transform = .identity
        }) { (success) in
            self.animateImage()
        }
        
        pocketbookView.alpha = 1
    }
    
    func animateLabel() {
        guard viewHasDisapperaed == false else {return}
        UIView.animate(withDuration: 1.0, animations: {
            self.lblGettingThingsReady.alpha = 1.0
        }) { (success) in
            
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveLinear, animations: {
                self.lblGettingThingsReady.alpha = 0
            }, completion: { (success) in
                self.animateLabel()
            })
        }
    }
    
    func fetchInformation() {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        AccountController.shared.fetchAccountsFromCloudKit { (complete) in
            guard complete else {self.presentErrorAlert(); return}
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        TransactionController.shared.fetchTransActionsFromCloudKit { (complete) in
            guard complete else {self.presentErrorAlert(); return}
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        BudgetItemController.shared.fetchBugetItemFromCloudKit { (complete) in
            guard complete else {self.presentErrorAlert(); return}
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        PlannedExpenseController.shared.fetchPlannedExpensesFromCloudKit { (complete) in
            guard complete else {self.presentErrorAlert(); return}
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        UserController.shared.fetchUserFromCloudKit { (complete) in
            guard complete else {self.presentErrorAlert(); return}
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            DispatchQueue.main.async {
                Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (_) in
                    self.presentOverTabVC()
                })
            }
        }
    }
    
    func presentErrorAlert() {
        presentSimpleAlert(controllerToPresentAlert: self, title: "We Ran Into A Problem!", message: "Check your internet connection and try agian!")
    }
    
    func presentOverTabVC() {
        let storyboard = UIStoryboard(name: "OverviewTabBar", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "OverviewVC")
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
        
    }
}
