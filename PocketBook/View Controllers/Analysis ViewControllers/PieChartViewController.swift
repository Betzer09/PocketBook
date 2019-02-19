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
            updatePieChart()
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
    
    // MARK: - Outlets
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var legendView: UIView!
    @IBOutlet weak var timeFramePickerView: UIPickerView!
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var whiteCircle: PieChartView!
    @IBOutlet weak var noDataImageView: UIImageView!
    
    // MARK: - Actions

    
    // MARK: - View LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        pieChartView.createLegendView(fromView: legendView)
        setUpPickerViews()
        setUpTimeFrameVar()
        view.setNeedsDisplay()
        configureNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        noDataImageSetup()
        
        // Uses to be "Total Spent by Budgeting Categories"
        // Percentage of total spent
        self.parent?.navigationItem.title = "Total Spent"
        updatePieChart()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - Setup UI
    func configureNavigationBar() {
        guard let font = UIFont(name: "Avenir Next", size: 17) else {return}
        let attributes = [ NSAttributedString.Key.font: font,
                           NSAttributedString.Key.foregroundColor : UIColor.white,
                           ]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.navigationItem.title = self.navigationItem.title
    }
    
    func noDataImageSetup() {
        let budgetItems = getAllBudgetItemNames()
        let transactions = TransactionController.shared.transactions
        if transactions.count == 0 || budgetItems.count == 0 {
            noDataImageView.isHidden = false
        } else {
            noDataImageView.isHidden = true
        }
    }
    
    // MARK: - Setup ViewPicker
    func setUpPickerViews() {
        timeFramePickerView.dataSource = self
        timeFramePickerView.delegate = self
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
        timeFrame = name
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.text = timeFrames[row]
        pickerLabel.font = UIFont(name: Keys.avenirNext, size: 18)
        pickerLabel.textAlignment = .center
        return pickerLabel
    }
    
    // MARK: - Setup Vars and Reload Functions
    func setUpTimeFrameVar() {
        timeFrame = TimeFrame.pastYear.rawValue
    }
    
    func updatePieChart() {
        let transactions: [Transaction] = TransactionController.shared.transactions
        guard let timeFrame = timeFrame else {return}
        let filteredTransactionType = filterByTransactionType(byThisType: TransactionType.expense.rawValue, forThisArray: transactions)
        let filteredByTime = filterByTimeFrame(withTimeVariable: timeFrame, forThisArray: filteredTransactionType)
        let filteredDictionary = filterByCategoryIntoDictionary(forThisArray: filteredByTime)
        pieChartView.formatPieChartViewAndLegend(withPieCharView: pieChartView, andLegendView: legendView, usingFilteredDictionary: filteredDictionary, withFontSize: 16)
        pieChartView.formatInnerCircle(fromPieChartView: whiteCircle)
        legendView.setNeedsDisplay()
    }

}
