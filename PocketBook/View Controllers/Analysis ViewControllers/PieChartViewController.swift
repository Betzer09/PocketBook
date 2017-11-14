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
            formatInnerCircle()
            legendView.setNeedsDisplay()
        }
    }
    
    let calendar = Calendar.autoupdatingCurrent
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
    
    // FOR TESTING
//    let transactions = [
//        Transaction(date: Date(), category: "Food", payee: "Wal-Mart", transactionType: "expense", amount: 50.00, account: "Savings"),
//        Transaction(date: Date(dateString: "2017-10-20"), category: "Gas", payee: "Chevron", transactionType: "expense", amount: 19.58, account: "Checking"),
//        Transaction(date: Date(dateString: "2016-12-20"), category: "Clothes", payee: "Target", transactionType: "expense", amount: 400.30, account: "Credit Card"),
//        Transaction(date: Date(dateString: "2017-01-01"), category: "CellPhone", payee: "Sprint", transactionType: "expense", amount: 99.00, account: "Checking"),
//        Transaction(date: Date(dateString: "2017-10-15"), category: "Food", payee: "Smiths", transactionType: "expense", amount: 47.39, account: "Checking"),
//        Transaction(date: Date(dateString: "2017-11-02"), category: "Food", payee: "Smiths", transactionType: "expense", amount: 28.34, account: "Checking")
//    ]
    
    let transactions = loop(number: 30)
    
    let categories: [String] = [
        "Food",
        "Gas",
        "Clothes",
        "Household",
        "CarPayment",
        "CellPhone",
        "TV/Internet",
        "Emergency",
        "Hospital Bills",
        "Cats",
        "Dogs",
        "Parrot",
        "Avacado",
        "Julius"
    ]
    
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
        configureLegendView()
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
    
    @objc func reloadView(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let localTimeFrame = userInfo[Keys.timeFrameKey] as? String else {return}
        DispatchQueue.main.async {
            self.timeFrame = localTimeFrame
            self.reloadInputViews()
        }
    }
    
    // MARK: - LEGEND AND PIE CHART
    
    // MARK: - Legend View
    func configureLegendView() {
        let frame = legendView.frame
        let allStackViews = UIStackView(frame: frame)
        legendView.addSubview(allStackViews)
        let stackView1 = UIStackView(frame: frame)
        let stackView2 = UIStackView(frame: frame)
        allStackViews.addArrangedSubview(stackView1)
        allStackViews.addArrangedSubview(stackView2)
        
        NSLayoutConstraint(item: allStackViews, attribute: .top, relatedBy: .equal, toItem: legendView, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: allStackViews, attribute: .bottom, relatedBy: .equal, toItem: legendView, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: allStackViews, attribute: .leading, relatedBy: .equal, toItem: legendView, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: allStackViews, attribute: .trailing, relatedBy: .equal, toItem: legendView, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        
        configureStackView(stackView: allStackViews, distribution: .fillEqually)
        configureStackView(stackView: stackView1, distribution: .fillProportionally)
        configureStackView(stackView: stackView2, distribution: .fillProportionally)
        
        createNameAndColorStacks(inSuperView: stackView1)
        createNameAndColorStacks(inSuperView: stackView2)
    }
    
    func configureStackView(stackView: UIStackView, distribution: UIStackViewDistribution) {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8.0
        stackView.distribution = distribution
    }
    
    func createNameAndColorStacks(inSuperView stackView: UIStackView) {
        let frame = legendView.frame
        let nameStackView = UIStackView(frame: frame)
        nameStackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(nameStackView)
        nameStackView.axis = .vertical
        nameStackView.spacing = 8.0
        nameStackView.distribution = .fillEqually
        
        let colorStackView = UIStackView(frame: frame)
        stackView.addArrangedSubview(colorStackView)
        colorStackView.translatesAutoresizingMaskIntoConstraints = false
        colorStackView.axis = .vertical
        colorStackView.spacing = 8.0
        colorStackView.distribution = .fillEqually
        NSLayoutConstraint(item: colorStackView, attribute: .width, relatedBy: .equal, toItem: stackView, attribute: .width, multiplier: 1/4, constant: 0).isActive = true
    }
    
    // MARK: - Setup PieChart
    func formatPieChartViewAndLegend(){
        guard let nameStackView = legendView.subviews[0].subviews[0].subviews[0] as? UIStackView,
            let colorStackView = legendView.subviews[0].subviews[0].subviews[1] as? UIStackView,
            let nameStackView2 = legendView.subviews[0].subviews[1].subviews[0] as? UIStackView,
            let colorStackView2 = legendView.subviews[0].subviews[1].subviews[1] as? UIStackView else {return}
        nameStackView.subviews.forEach { $0.removeFromSuperview() }
        colorStackView.subviews.forEach{ $0.removeFromSuperview() }
        nameStackView2.subviews.forEach { $0.removeFromSuperview() }
        colorStackView2.subviews.forEach{ $0.removeFromSuperview() }

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
        
        guard let dictionary = filteredTransactionDictionary else {return}
        for catagory in categories {
            
            guard let value = dictionary[catagory], value != 0.0 else {continue}
            
            if colors.count <= count {
                let colorRandom = getRandomColor()
                colors.append(colorRandom)
            }
            let color = colors[count]
            let segment = Segment(color: color, value: CGFloat(value))
            segments.append(segment)
            
            if count % 2 == 0 {
            addNameAndColorLabel(nameStackView: nameStackView, colorStackView: colorStackView, catagory: catagory, color: color)
            }
            else {
                addNameAndColorLabel(nameStackView: nameStackView2, colorStackView: colorStackView2, catagory: catagory, color: color)
            }
            
            count += 1
            }
        
        if count % 2 != 0 {
            addNameAndColorLabel(nameStackView: nameStackView2, colorStackView: colorStackView2, catagory: "", color: .white)
        }
        
        pieChartView.segments = segments
    }
    
    
    func addNameAndColorLabel(nameStackView: UIStackView, colorStackView: UIStackView, catagory: String, color: UIColor) {
        let frame = CGRect(x: 0, y: 0, width: 50, height: 25)
        
        let nameLabel = UILabel(frame: frame)
        nameStackView.addArrangedSubview(nameLabel)
        nameLabel.text = catagory
        nameLabel.textAlignment = .right
//        NSLayoutConstraint(item: nameLabel, attribute: .width, relatedBy: .equal, toItem: nameStackView, attribute: .width, multiplier: 1, constant: 0).isActive = true
        
        let colorLabel = UILabel(frame: frame)
        colorStackView.addArrangedSubview(colorLabel)
        colorLabel.text = "     "
        colorLabel.textAlignment = .center
        colorLabel.backgroundColor = color
    }
    
    func getRandomColor() -> UIColor{
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    // MARK: - White Circle
    func formatInnerCircle() {
        let segments = [
        Segment(color: .white, value: 1)
        ]
        whiteCircle.segments = segments
        whiteCircle.backgroundColor = .clear
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
