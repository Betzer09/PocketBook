//
//  PlannedExpensesLineGraphViewController.swift
//  PocketBook
//
//  Created by Michael Meyers on 11/9/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class PlannedExpensesLineGraphViewController: UIPageViewController {
    
    var timeFrame: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView(notification:)), name: Notifications.sendingTimeFrameInfoToVCs, object: nil)

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: Notifications.viewControllerHasFinishedLoading, object: nil, userInfo: nil)
    }
    
    // MARK: - Setup Functions
    @objc func reloadView(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let localTimeFrame = userInfo[Keys.timeFrameKey] as? String else {return}
        DispatchQueue.main.async {
            self.timeFrame = localTimeFrame
            self.reloadInputViews()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
