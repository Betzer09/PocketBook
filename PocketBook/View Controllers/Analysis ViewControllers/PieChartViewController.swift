//
//  PieChartViewController.swift
//  PocketBook
//
//  Created by Michael Meyers on 11/9/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class PieChartViewController: UIPageViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: - Properties
    var timeFrame: String?
    let calendar = Calendar.autoupdatingCurrent
    let transactions: [Transaction] = TransactionController.shared.transactions
    var filteredByTimeFrameTransactions: [Transaction]?
    var filteredTransactionDictionary: [String: Double]?
    
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
    
    var currentYear: Int? {
        let current = calendar.dateComponents([.year, .month], from: Date())
        guard let year = current.year else {return nil}
        return year
    }
    
    var currentMonth: Int? {
        let current = calendar.dateComponents([.year, .month], from: Date())
        guard let month = current.month else {return nil}
        return month
    }
    
    
    // MARK: - Outlets
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var legendView: UIView!
    @IBOutlet weak var timeFramePickerView: UIPickerView!
    @IBOutlet weak var timeFrameButton: UIButton!
    
    // MARK: - Actions
    @IBAction func timeFrameButtonTapped(_ sender: UIButton) {
        timeFramePickerView.isHidden = false
    }
    
    // MARK: - View LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView(notification:)), name: Notifications.sendingTimeFrameInfoToVCs, object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: Notifications.viewControllerHasFinishedLoading, object: nil, userInfo: nil)
    }
    
    // MARK: - Setup ViewPicker
    
    func setUpPickerViews() {
        timeFramePickerView.dataSource = self
        timeFramePickerView.delegate = self
        timeFramePickerView.isHidden = true
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == timeFramePickerView {
            return timeFrames.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == timeFramePickerView {
            return timeFrames[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == timeFramePickerView {
            let name = timeFrames[row]
            timeFrameButton.setTitle(name, for: .normal)
            timeFrame = name
            view.reloadInputViews()
        }
    }
    
    // MARK: - Setup Functions
    
    func setUpTimeFrameVar() {
        timeFrameButton.setTitle(timeFrames[0], for: .normal)
        timeFrame = timeFrameButton.titleLabel?.text
    }
    
    @objc func reloadView(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let localTimeFrame = userInfo[Keys.timeFrameKey] as? String else {return}
        DispatchQueue.main.async {
            self.timeFrame = localTimeFrame
            self.reloadInputViews()
        }
    }
    
    // TODO FIX THIS CODE
    // MARK: - Setup PieChart
    func createPieChart(){
        let colors: [UIColor] = []
        let pieChart2 = PieChartView()
        pieChart2.frame = pieChartView.frame
        var segments2: [Segment] = []
        var count = 0
        for string in categories {
            let segment = Segment(color: colors[count], value: 0)
            count += 1
            segments2.append(segment)
        }
        pieChart2.segments = segments2
        view.addSubview(pieChart2)
        
        pieChartView.center = pieChart2.center
        let whiteCircle = PieChartView()
        whiteCircle.frame = CGRect(x: 0, y: 0, width: pieChart2.frame.width/3, height: pieChart2.frame.height/3)
        whiteCircle.center = pieChart2.center
        whiteCircle.segments = [
            Segment(color: .white, value: 150)
        ]
        view.addSubview(whiteCircle)
    }
    
    // MARK: - Filter Transactions
    func filterTransactionsByTimeFrame(){
        
        guard let text = timeFrame else {return}
        var internalFilteredTransactions: [Transaction] = []
        switch text {
        case TimeFrame.pastYear.rawValue:
            for transaction in transactions {
                guard let month = currentMonth,
                    let year = currentYear else {return}
                let calendarDate = calendar.dateComponents([.year, .month], from: transaction.date)
                guard let dateMonth = calendarDate.month,
                    let dateYear = calendarDate.year else {return}
                if dateYear == year {
                    if dateMonth <= month {
                        internalFilteredTransactions.append(transaction)
                    }
                }
                if dateYear == (year - 1) {
                    if dateMonth > month {
                        internalFilteredTransactions.append(transaction)
                    }
                }
            }
        case TimeFrame.yearToDate.rawValue:
            for transaction in transactions {
                guard let month = currentMonth,
                    let year = currentYear else {return}
                let calendarDate = calendar.dateComponents([.year, .month], from: transaction.date)
                guard let dateMonth = calendarDate.month,
                    let dateYear = calendarDate.year else {return}
                if dateYear == year {
                    if dateMonth <= month {
                        internalFilteredTransactions.append(transaction)
                    }
                }
            }
        case TimeFrame.lastMonth.rawValue:
            for transaction in transactions {
                guard let month = currentMonth,
                    let year = currentYear else {return}
                let calendarDate = calendar.dateComponents([.year, .month], from: transaction.date)
                guard let dateMonth = calendarDate.month,
                    let dateYear = calendarDate.year else {return}
                if dateYear == year {
                    if dateMonth == (month - 1) {
                        internalFilteredTransactions.append(transaction)
                    }
                }
            }
        case TimeFrame.thisMonth.rawValue:
            for transaction in transactions {
                guard let month = currentMonth,
                    let year = currentYear else {return}
                let calendarDate = calendar.dateComponents([.year, .month], from: transaction.date)
                guard let dateMonth = calendarDate.month,
                    let dateYear = calendarDate.year else {return}
                if dateYear == year {
                    if dateMonth == month {
                        internalFilteredTransactions.append(transaction)
                    }
                }
            }
        default:
            filteredByTimeFrameTransactions = transactions
        }
        filteredByTimeFrameTransactions = internalFilteredTransactions
    }
    
    func filterTransactionsByCategory() {
        var internalFilteredTransactionsDictionary: [String: Double] = [:]
        for category in categories {
            guard let filteredTransactions = filteredByTimeFrameTransactions else {return}
            var categoryTotal = 0.0
            for transaction in filteredTransactions {
                if transaction.catagory == category {
                    categoryTotal += transaction.amount
                }
            }
            internalFilteredTransactionsDictionary[category] = categoryTotal
        }
        filteredTransactionDictionary = internalFilteredTransactionsDictionary
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
