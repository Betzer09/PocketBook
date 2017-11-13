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
            filterTransactionsByTimeFrame()
            filterTransactionsByCategory()
            formatPieChartViewAndLegend()
            legendView.setNeedsDisplay()
        }
    }
    
    let calendar = Calendar.autoupdatingCurrent
    // FOR TESTING
    let transactions = loop(number: 40)
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
    
//    var categories: [String] {
//        let budgetItems = BudgetItemController.shared.budgetItems
//        var names: [String] = []
//        for budgetItem in budgetItems {
//            names.append(budgetItem.name)
//        }
//        return names
//    }
    
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
    @IBOutlet weak var superView: UIView!
    
    // MARK: - Actions
    @IBAction func timeFrameButtonTapped(_ sender: UIButton) {
        timeFramePickerView.isHidden = false
    }
    
    // MARK: - View LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLegendView()
        setUpPickerViews()
        setUpTimeFrameVar()
        createInnerCircle()
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
    func formatPieChartViewAndLegend(){
        guard let nameStackView = legendView.subviews[0].subviews[0] as? UIStackView,
            let colorStackView = legendView.subviews[0].subviews[1] as? UIStackView else {return}
        nameStackView.subviews.forEach { $0.removeFromSuperview() }
        colorStackView.subviews.forEach{ $0.removeFromSuperview() }

        var colors: [UIColor] = [
            // Make Colors Array longer
            .red,
            .blue,
            .green,
            .magenta,
            .yellow,
            .purple,
            .orange,
            .cyan
        ]
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
            let frame = CGRect(x: 0, y: 0, width: 50, height: 25)
            
            let nameLabel = UILabel(frame: frame)
            nameStackView.addArrangedSubview(nameLabel)
            nameLabel.text = catagory
            nameLabel.textAlignment = .center
            NSLayoutConstraint(item: nameLabel, attribute: .width, relatedBy: .equal, toItem: nameStackView, attribute: .width, multiplier: 1/2, constant: 0).isActive = true
            
            let colorLabel = UILabel(frame: frame)
            colorStackView.addArrangedSubview(colorLabel)
            colorLabel.text = ""
            colorLabel.textAlignment = .center
            colorLabel.backgroundColor = color
            NSLayoutConstraint(item: colorLabel, attribute: .width, relatedBy: .equal, toItem: colorStackView, attribute: .width, multiplier: 1/4, constant: 0).isActive = true
            
            count += 1
            segments.append(segment)
        }
        pieChartView.segments = segments
    }
    
    func createInnerCircle() {
        let frame = CGRect(x: 0, y: 0, width: pieChartView.frame.width/2, height: pieChartView.frame.height/2)
        let whiteCircle = PieChartView(frame: frame)
        whiteCircle.segments = [
        Segment(color: .white, value: 1)
        ]
        pieChartView.addSubview(whiteCircle)
        let x = pieChartView.frame.maxX/2
        let y = pieChartView.frame.maxY/2
        whiteCircle.center = CGPoint(x: x, y: y)
    }
    
    func configureLegendView() {
        let frame = legendView.frame
        let bothStackView = UIStackView(frame: frame)
        legendView.addSubview(bothStackView)

        NSLayoutConstraint(item: bothStackView, attribute: .top, relatedBy: .equal, toItem: legendView, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: bothStackView, attribute: .bottom, relatedBy: .equal, toItem: legendView, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: bothStackView, attribute: .leading, relatedBy: .equal, toItem: legendView, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: bothStackView, attribute: .trailing, relatedBy: .equal, toItem: legendView, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true

        bothStackView.translatesAutoresizingMaskIntoConstraints = false
        bothStackView.axis = .horizontal
        bothStackView.spacing = 8.0
        bothStackView.distribution = .fillEqually
        
//        let label = UILabel(frame: frame)
//        label.backgroundColor = .blue
        let nameStackView = UIStackView(frame: frame)
//        nameStackView.addSubview(label)
//        nameStackView.addSubview(label)
//        nameStackView.addSubview(label)
        nameStackView.translatesAutoresizingMaskIntoConstraints = false
        bothStackView.insertArrangedSubview(nameStackView, at: 0)
        nameStackView.axis = .vertical
        nameStackView.spacing = 8.0
        nameStackView.distribution = .fillEqually
        nameStackView.alignment = .trailing
        
        let colorStackView = UIStackView(frame: frame)
        bothStackView.insertArrangedSubview(colorStackView, at: 1)
        colorStackView.translatesAutoresizingMaskIntoConstraints = false
        colorStackView.axis = .vertical
        colorStackView.spacing = 8.0
        colorStackView.distribution = .fillEqually
        colorStackView.alignment = .leading
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
            var lastMonth: Int
            guard let month = currentMonth,
                let year = currentYear else {return}
            if month == 1 {
                lastMonth = 12
            } else {
                lastMonth = month - 1
            }
            for transaction in transactions {
                let calendarDate = calendar.dateComponents([.year, .month], from: transaction.date)
                guard let dateMonth = calendarDate.month,
                    let dateYear = calendarDate.year else {return}
                print(dateYear)
                print(dateMonth)
                if dateYear == year {
                    if dateMonth == (lastMonth) {
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
                print(dateYear)
                print(dateMonth)
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
                if transaction.category == category {
                    categoryTotal += transaction.amount
                }
            }
            internalFilteredTransactionsDictionary[category] = categoryTotal
        }
        filteredTransactionDictionary = internalFilteredTransactionsDictionary
        
    }
}
