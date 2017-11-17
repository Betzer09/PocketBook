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
            let filteredTransactionType = filterByTransactionType(byThisType: TransactionType.income.rawValue, forThisArray: transactions)
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

}
