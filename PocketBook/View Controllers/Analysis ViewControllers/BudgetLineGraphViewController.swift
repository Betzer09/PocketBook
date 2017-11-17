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
        let budgetItems = BudgetItemController.shared.budgetItems
        var names: [String] = []
        for budgetItem in budgetItems {
            names.append(budgetItem.name)
        }
        return names
    }
    
    // MARK: - Outlets
    @IBOutlet weak var timeFrameButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var timeFramePickerView: UIPickerView!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    @IBOutlet weak var yView: UIView!
    @IBOutlet weak var xView: UIView!
    @IBOutlet weak var lineGraphView: LineGraphView!
    
    // MARK: - Actions
    @IBAction func timeFrameButtonTapped(_ sender: UIButton) {
        timeFramePickerView.isHidden = false
        categoryButton.isHidden = true
    }
    
    @IBAction func categoryButtonTapped(_ sender: UIButton) {
        categoryPickerView.isHidden = false
        timeFrameButton.isHidden = true
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPickerViews()
        setUpCategoryVar()
        setUpTimeFrameVar()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: Notifications.viewControllerHasFinishedLoading, object: nil, userInfo: nil)
    }
    
    // MARK: - Setup PickerViews
    func setUpPickerViews() {
        categoryPickerView.dataSource = self
        categoryPickerView.delegate = self
        categoryPickerView.isHidden = true
        
        timeFramePickerView.dataSource = self
        timeFramePickerView.delegate = self
        timeFramePickerView.isHidden = true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == categoryPickerView {
            return categories.count
        }
        if pickerView == timeFramePickerView {
            return timeFrames.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == categoryPickerView {
            return categories[row]
        }
        if pickerView == timeFramePickerView {
            return timeFrames[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == categoryPickerView {
            let name = categories[row]
            categoryButton.setTitle(name, for: .normal)
            category = name
            timeFrameButton.isHidden = false
            pickerView.isHidden = true
        }
        if pickerView == timeFramePickerView {
            let name = timeFrames[row]
            timeFrameButton.setTitle(name, for: .normal)
            timeFrame = name
            categoryButton.isHidden = false
            pickerView.isHidden = true
        }
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
    func setUpTimeFrameVar() {
        timeFrameButton.setTitle("Past Year", for: .normal)
    }
    
    func setUpCategoryVar() {
        let categoryString = categories[0]
        categoryButton.setTitle(categoryString, for: .normal)
        category = categoryString
    }
}
