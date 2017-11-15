//
//  PieChartViewController.swift
//  PocketBook
//
//  Created by Michael Meyers on 11/9/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class PieChartViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: - Properties
    var timeFrame: String? {
        didSet {
            guard let timeFrame = timeFrame else {return}
            let filterByTime = filterByTimeFrame(withTimeVariable: timeFrame, forThisArray: transactions)
            let filteredDictionary = filterByCategoryIntoDictionary(forThisArray: filterByTime)
            PieChartView.shared.formatPieChartViewAndLegend(withPieCharView: pieChartView, andLegendView: legendView, usingFilteredDictionary: filteredDictionary)
            PieChartView.shared.formatInnerCircle(fromPieChartView: whiteCircle)
            legendView.setNeedsDisplay()
        }
    }
    
    let transactions: [Transaction] = TransactionController.shared.transactions
    
    var timeFrames: [String] {
        var array: [String] = []
        array.append(TimeFrame.pastYear.rawValue)
        array.append(TimeFrame.yearToDate.rawValue)
        array.append(TimeFrame.lastMonth.rawValue)
        array.append(TimeFrame.thisMonth.rawValue)
        return array
    }
    
    // FOR TESTING
    //    let transactions = [
    //        Transaction(date: Date(), category: "Food", payee: "Wal-Mart", transactionType: "expense", amount: 50.00, account: "Savings"),
    //        Transaction(date: Date(dateString: "2017-10-20"), category: "Gas", payee: "Chevron", transactionType: "expense", amount: 19.58, account: "Checking"),
    //        Transaction(date: Date(dateString: "2016-12-20"), category: "Clothes", payee: "Target", transactionType: "expense", amount: 400.30, account: "Credit Card"),
    //        Transaction(date: Date(dateString: "2017-01-01"), category: "CellPhone", payee: "Sprint", transactionType: "expense", amount: 99.00, account: "Checking"),
    //        Transaction(date: Date(dateString: "2017-10-15"), category: "Food", payee: "Smiths", transactionType: "expense", amount: 47.39, account: "Checking"),
    //        Transaction(date: Date(dateString: "2017-11-02"), category: "Food", payee: "Smiths", transactionType: "expense", amount: 28.34, account: "Checking")
    //    ]
    
    //    let transactions = loop(number: 30)
    //
    //    let categories: [String] = [
    //        "Food",
    //        "Gas",
    //        "Clothes",
    //        "Household",
    //        "CarPayment",
    //        "CellPhone",
    //        "TV/Internet",
    //        "Emergency",
    //        "Hospital Bills",
    //        "Cats",
    //        "Dogs",
    //        "Parrot",
    //        "Avacado",
    //        "Julius"
    //    ]
    
    // MARK: - Outlets
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var legendView: UIView!
    @IBOutlet weak var timeFrameButton: UIButton!
    @IBOutlet weak var timeFramePickerView: UIPickerView!
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var whiteCircle: PieChartView!
    
    
    // MARK: - Actions
    @IBAction func timeFrameButtonTapped(_ sender: UIButton) {
        timeFramePickerView.isHidden = false
    }
    
    // MARK: - View LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        PieChartView.shared.createLegendView(fromView: legendView)
        setUpPickerViews()
        setUpTimeFrameVar()
        view.setNeedsDisplay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        return timeFrames.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timeFrames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let name = timeFrames[row]
        timeFrameButton.setTitle(name, for: .normal)
        timeFrame = name
        pickerView.isHidden = true
    }
    
    // MARK: - Setup Vars and Reload Functions
    
    func setUpTimeFrameVar() {
        timeFrameButton.setTitle(timeFrames[0], for: .normal)
        timeFrame = timeFrameButton.titleLabel?.text
    }
    
//    @objc func reloadView(notification: Notification) {
//        guard let userInfo = notification.userInfo,
//            let localTimeFrame = userInfo[Keys.timeFrameKey] as? String else {return}
//        DispatchQueue.main.async {
//            self.timeFrame = localTimeFrame
//            self.reloadInputViews()
//        }
//    }
}
