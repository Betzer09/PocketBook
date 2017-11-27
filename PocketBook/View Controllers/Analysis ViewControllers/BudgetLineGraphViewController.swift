//
//  BudgetLineGraphViewController.swift
//  PocketBook
//
//  Created by Michael Meyers on 11/9/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class BudgetLineGraphViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Properties
    var timeFrame: String = "Past Year" {
        didSet {
            guard let category = category else {return}
            let transactions: [Transaction] = TransactionController.shared.transactions
            let filteredTransactionType = filterByTransactionType(byThisType: TransactionType.expense.rawValue, forThisArray: transactions)
            let filteredByTimeFrame = filterByTimeFrame(withTimeVariable: timeFrame, forThisArray: filteredTransactionType)
            let filteredByCategory = filterByCategoryIntoArray(forCategory: category, forThisArray: filteredByTimeFrame)
            let totals = LineGraphView.shared.calculateTotalsArray(fromTransactions: filteredByCategory, withTimeFrame: timeFrame, andCategory: category)
            LineGraphView.shared.configureLineGraph(lineGraphView: lineGraphView, xView: xView, yView: yView, forTotals: totals, withTimeFrame: timeFrame, andCategory: category, viewControllerToPresentAlert: self)
            view.setNeedsDisplay()
        }
    }
    
    var category: String? {
        didSet {
            guard let category = category else {return}
            let transactions: [Transaction] = TransactionController.shared.transactions
            let filteredTransactionType = filterByTransactionType(byThisType: TransactionType.expense.rawValue, forThisArray: transactions)
            let filteredByTimeFrame = filterByTimeFrame(withTimeVariable: timeFrame, forThisArray: filteredTransactionType)
            let filteredByCategory = filterByCategoryIntoArray(forCategory: category, forThisArray: filteredByTimeFrame)
            let totals = LineGraphView.shared.calculateTotalsArray(fromTransactions: filteredByCategory, withTimeFrame: timeFrame, andCategory: category)
            LineGraphView.shared.configureLineGraph(lineGraphView: lineGraphView, xView: xView, yView: yView, forTotals: totals, withTimeFrame: timeFrame, andCategory: category, viewControllerToPresentAlert: self)
            view.setNeedsDisplay()
        }
    }
    
    var timeFrames: [String] {
        var array: [String] = []
        array.append(TimeFrame.pastYear.rawValue)
        array.append(TimeFrame.yearToDate.rawValue)
        array.append(TimeFrame.lastMonth.rawValue)
        array.append(TimeFrame.thisMonth.rawValue)
        return array
    }
    
    var categories: [String] {
        return getAllBudgetItemNames()
    }
    
    // MARK: - Outlets
    @IBOutlet weak var yView: UIView!
    @IBOutlet weak var xView: UIView!
    @IBOutlet weak var lineGraphView: LineGraphView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCategoryVar()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpPickerViews()
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: Notifications.viewControllerHasFinishedLoading, object: nil, userInfo: nil)
    }
    
    // MARK: - Setup PickerViews
    func setUpPickerViews() {
        pickerView.dataSource = self
        pickerView.delegate = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return timeFrames.count
        }
        if component == 1 {
            return categories.count
        }
        else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return timeFrames[row]
        }
        if component == 1 {
            return categories[row]
        }
        else {
            return "?"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            let name = timeFrames[row]
            timeFrame = name
        }
        if component == 1 {
            let name = categories[row]
            category = name
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        if component == 0 {
            pickerLabel.text = timeFrames[row]
        }
        if component == 1 {
            pickerLabel.text = categories[row]
        }
        pickerLabel.font = UIFont(name: "Arial", size: 15)
        pickerLabel.textAlignment = .center
        return pickerLabel
    }
    
    // MARK: - Notification Functions
    @objc func reloadView(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let localTimeFrame = userInfo[Keys.timeFrameKey] as? String else {return}
        DispatchQueue.main.async {
            self.timeFrame = localTimeFrame
            self.reloadInputViews()
        }
    }
    
    // MARK: - Setup Line Graph Views
    
    func setUpCategoryVar() {
        if categories.isEmpty == true {
            return
        } else {
        let categoryString = categories[0]
        category = categoryString
        }
    }
}
