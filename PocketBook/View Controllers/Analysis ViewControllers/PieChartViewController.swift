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
    var timeFrame: String? {
        didSet {
            filterTransactionsByTimeFrame()
            filterTransactionsByCategory()
            self.reloadInputViews()
        }
    }
    
    let calendar = Calendar.autoupdatingCurrent
    let transactions = loop(number: 300)
//    let transactions: [Transaction] = TransactionController.shared.transactions
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
    @IBOutlet  var pieChartView: PieChartView!
    @IBOutlet  var legendView: UIView!
    @IBOutlet  var timeFrameButton: UIButton!
    @IBOutlet  var timeFramePickerView: UIPickerView!
    
    // MARK: - Actions
    @IBAction func timeFrameButtonTapped(_ sender: UIButton) {
        timeFramePickerView.isHidden = false
    }
    
    // MARK: - View LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpPickerViews()
        setUpTimeFrameVar()
        createPieChart()
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
        }
    }
    
    // MARK: - Setup Vars and Reload Functions
    
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
    
    // TODO FIX THIS CODE FOR THE DIFFERENT VIEWS
    //
    // MARK: - Setup PieChart
    func createPieChart(){
        configureLegendView()
        let nameStackView = legendView.subviews[0].subviews[0]
        let colorStackView = legendView.subviews[0].subviews[1]
        var colors: [UIColor] = [
            .red,
            .blue,
            .green,
            .magenta,
            .yellow,
            .purple,
            .orange,
            .cyan
        ]
        let pieChart = PieChartView()
        pieChart.frame = pieChartView.frame
        var segments: [Segment] = []
        var count = 0
        for catagory in categories {
            guard let dictionary = filteredTransactionDictionary,
            let value = dictionary[catagory] else {return}
            if colors.count <= count {
                let colorRandom = getRandomColor()
                colors.append(colorRandom)
            }
            let color = colors[count]
            let segment = Segment(color: color, value: CGFloat(value))
            let nameLabel = UILabel()
            nameLabel.text = catagory
            nameStackView.addSubview(nameLabel)
            let colorLabel = UILabel()
            colorLabel.text = ""
            colorLabel.backgroundColor = color
            colorStackView.addSubview(colorLabel)
            count += 1
            segments.append(segment)
        }
        pieChart.segments = segments
        pieChartView.center = pieChart.center
        pieChartView.addSubview(pieChart)
        
        let whiteCircle = PieChartView()
        whiteCircle.frame = CGRect(x: 0, y: 0, width: pieChart.frame.width/3, height: pieChart.frame.height/3)
        whiteCircle.center = pieChart.center
        whiteCircle.segments = [
            Segment(color: .white, value: 150)
        ]
        pieChartView.addSubview(whiteCircle)
    }
    
    func configureLegendView() {
        let colorStackView = UIStackView()
        colorStackView.axis = .vertical
        colorStackView.spacing = 8.0
        let nameStackView = UIStackView()
        nameStackView.axis = .vertical
        nameStackView.spacing = 8.0
        let bothStackView = UIStackView()
        bothStackView.axis = .horizontal
        bothStackView.spacing = 8.0
        bothStackView.insertArrangedSubview(nameStackView, at: 0)
        bothStackView.insertArrangedSubview(colorStackView, at: 1)
        bothStackView.frame = legendView.frame
        legendView.addSubview(bothStackView)
    }
    
    func getRandomColor() -> UIColor{
        
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
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
}
