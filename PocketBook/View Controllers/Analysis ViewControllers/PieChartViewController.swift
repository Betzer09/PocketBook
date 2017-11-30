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
            let transactions: [Transaction] = TransactionController.shared.transactions
            guard let timeFrame = timeFrame else {return}
            let filteredTransactionType = filterByTransactionType(byThisType: TransactionType.expense.rawValue, forThisArray: transactions)
            let filteredByTime = filterByTimeFrame(withTimeVariable: timeFrame, forThisArray: filteredTransactionType)
            let filteredDictionary = filterByCategoryIntoDictionary(forThisArray: filteredByTime)
            PieChartView.shared.formatPieChartViewAndLegend(withPieCharView: pieChartView, andLegendView: legendView, usingFilteredDictionary: filteredDictionary)
            PieChartView.shared.formatInnerCircle(fromPieChartView: whiteCircle)
            legendView.setNeedsDisplay()
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
    
    @IBOutlet weak var pcSelectedView: UIView!
    @IBOutlet weak var pcOtherView1: UIView!
    @IBOutlet weak var pcOtherView2: UIView!
    // MARK: - Actions

    
    // MARK: - View LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        PieChartView.shared.createLegendView(fromView: legendView)
        setUpPickerViews()
        setUpTimeFrameVar()
        view.setNeedsDisplay()
        configureNavigationBar()
        configurePageControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        noDataImageSetup()
        self.parent?.navigationItem.title = "Total Spent by Budgeting Categories".uppercased()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - Setup UI
    func configureNavigationBar() {
        guard let font = UIFont(name: "Avenir Next", size: 17) else {return}
        let attributes = [ NSAttributedStringKey.font: font,
                           NSAttributedStringKey.foregroundColor : UIColor.white,
                           ]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.navigationItem.title = self.navigationItem.title?.uppercased()
    }
    
    func configurePageControl() {
        pcSelectedView.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.5)
        pcSelectedView.layer.cornerRadius = pcSelectedView.frame.height/2
        pcOtherView1.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.15)
        pcOtherView1.layer.cornerRadius = pcOtherView1.frame.height/2
        pcOtherView2.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.15)
        pcOtherView2.layer.cornerRadius = pcOtherView2.frame.height/2
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
    
    // MARK: - Setup Vars and Reload Functions
    func setUpTimeFrameVar() {
        timeFrame = TimeFrame.pastYear.rawValue
    }

}
