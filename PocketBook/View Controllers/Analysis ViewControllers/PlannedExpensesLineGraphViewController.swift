//
//  PlannedExpensesLineGraphViewController.swift
//  PocketBook
//
//  Created by Michael Meyers on 11/9/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class PlannedExpensesLineGraphViewController: UIPageViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    // MARK: - Properties
    var timeFrame: String? {
        didSet {
            filterTransactionsByTimeFrame()
            filterTransactionsByCategory()
            reloadInputViews()
        }
    }
    var category: String? {
        didSet {
            filterTransactionsByCategory()
            reloadInputViews()
        }
    }
    
    var dots: [UIView] = []
    let calendar = Calendar.autoupdatingCurrent
    let transactions = loop(number: 300)
//    let transactions: [Transaction] = TransactionController.shared.transactions
    var filteredByTimeFrameTransactions: [Transaction]?
    var filteredByCatagoryTransactions: [Transaction]?
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
    
    var timeFrames: [String] {
        var array: [String] = []
        array.append(TimeFrame.pastYear.rawValue)
        array.append(TimeFrame.yearToDate.rawValue)
        return array
    }
    
    var categories: [String] {
        let plannedExpenses = PlannedExpenseController.shared.plannedExpenses
        var names: [String] = []
        for plannedExpense in plannedExpenses {
            names.append(plannedExpense.name)
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
    }
    
    @IBAction func categoryButtonTapped(_ sender: UIButton) {
        categoryPickerView.isHidden = false
        categoryPickerView.transform = CGAffineTransform()
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView(notification:)), name: Notifications.sendingTimeFrameInfoToVCs, object: nil)
        
        
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
            view.reloadInputViews()
        }
        if pickerView == timeFramePickerView {
            let name = timeFrames[row]
            timeFrameButton.setTitle(name, for: .normal)
            timeFrame = name
            view.reloadInputViews()
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
        timeFrameButton.setTitle(timeFrames[0], for: .normal)
        timeFrame = timeFrameButton.titleLabel?.text
    }
    
    func setUpCategoryVar() {
        categoryButton.setTitle(categories[0], for: .normal)
        category = categoryButton.titleLabel?.text
    }
    
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
        default:
            filteredByTimeFrameTransactions = transactions
        }
        filteredByTimeFrameTransactions = internalFilteredTransactions
    }
    
    func filterTransactionsByCategory() {
        var internalFilteredTransactions: [Transaction] = []
        guard let name = category,
            let filteredTransactions = filteredByTimeFrameTransactions else {return}
        for transaction in filteredTransactions {
            if transaction.catagory == name {
                internalFilteredTransactions.append(transaction)
            }
        }
        filteredByCatagoryTransactions = internalFilteredTransactions
    }
    
    func configureLineGraph() {
        
        var distanceOfEachXCatagory: CGFloat = 0
        var time: Int = 0
        var array: [String] = []
        var totals: [Double] = []
        guard let filteredByCatagoryTransactions = filteredByCatagoryTransactions else {return}
        guard let text = timeFrame else {return}
        switch text {
        case TimeFrame.pastYear.rawValue:
            time = 12
            guard let month = currentMonth else {return}
            var count = month - 1
            while count < 12 {
                let month = monthsOfTheYear[count]
                array.append(month)
                var total: Double = 0.0
                for transaction in filteredByCatagoryTransactions {
                    let thisCount = count + 1
                    let calendarDate = calendar.dateComponents([.month, .year], from: transaction.date)
                    if thisCount == calendarDate.month {
                        total += transaction.amount
                    }
                }
                totals.append(total)
                count += 1
            }
            count = 0
            while count < month - 1 {
                let month = monthsOfTheYear[count]
                array.append(month)
                var total: Double = 0.0
                for transaction in filteredByCatagoryTransactions {
                    let thisCount = count + 1
                    let calendarDate = calendar.dateComponents([.month, .year], from: transaction.date)
                    if thisCount == calendarDate.month {
                        total += transaction.amount
                    }
                }
                totals.append(total)
                count += 1
            }
        case TimeFrame.yearToDate.rawValue:
            guard let time = currentMonth else {return}
            for number in 1...time {
                let month = monthsOfTheYear[number - 1]
                array.append(month)
                var total: Double = 0.0
                for transaction in filteredByCatagoryTransactions {
                    let calendarDate = calendar.dateComponents([.month, .year], from: transaction.date)
                    if number == calendarDate.month {
                        total += transaction.amount
                    }
                }
                totals.append(total)
            }
        case TimeFrame.lastMonth.rawValue:
            time = 4
            array = weeksOfTheMonth
            guard let thisMonth = currentMonth else {return}
            let lastMonth = thisMonth - 1
            totals = calculateMonthTotals(transactions: filteredByCatagoryTransactions, month: lastMonth)
        case TimeFrame.thisMonth.rawValue:
            time = 4
            array = weeksOfTheMonth
            guard let thisMonth = currentMonth else {return}
            totals = calculateMonthTotals(transactions: filteredByCatagoryTransactions, month: thisMonth)
        default: fatalError()
        }
        distanceOfEachXCatagory = calculateDistanceOfEachXCatagory(number: time)
        createXView(time: time, array: array)
        createYView(totals: totals)
        createScatterPlot(xDistance: distanceOfEachXCatagory, totals: totals)
    }
    
    // MARK: - Calculate Functions
    
    func calculateMonthTotals(transactions: [Transaction], month: Int) -> [Double] {
        var localTotals: [Double] = []
        var week1Total: Double = 0
        var week2Total: Double = 0
        var week3Total: Double = 0
        var week4Total: Double = 0
        for transaction in transactions {
            let calendarDate = calendar.dateComponents([.month, .year, .day], from: transaction.date)
            if month == calendarDate.month {
                guard let day = calendarDate.day else {return []}
                if day <= 7 {
                    week1Total += transaction.amount
                }
                if day <= 14 {
                    week2Total += transaction.amount
                }
                if day <= 21 {
                    week3Total += transaction.amount
                }
                if day > 21 {
                    week4Total += transaction.amount
                }
            }
        }
        localTotals.append(week1Total)
        localTotals.append(week2Total)
        localTotals.append(week3Total)
        localTotals.append(week4Total)
        return localTotals
    }
    
    // MARK: - LineGraphView Setup
    func createDot(inView view:UIView, withCoordinatesX x: CGFloat, y: CGFloat) {
        let dot = UIView()
        let originY = (view.bounds.maxY - y)
        dot.frame = CGRect(x: x, y: originY, width: 7, height: 7)
        dot.backgroundColor = .green
        view.addSubview(dot)
        dots.append(dot)
    }
    
    func createScatterPlot(xDistance: CGFloat, totals: [Double]) {
        var segmentCount: CGFloat = 1
        for total in totals {
            guard let maxTotal = totals.max() else {return}
            let totals = maxTotal + (maxTotal * 0.1)
            let cgFloatTotal = calculatePercentValue(withBudgetItemSpentTotal: total, totalSpent:totals , maxY: lineGraphView.bounds.maxY)
            createDot(inView: lineGraphView, withCoordinatesX: segmentCount * xDistance, y:cgFloatTotal )
            segmentCount += 1
        }
        lineGraphView.dots = dots
        lineGraphView.setNeedsDisplay()
    }
    
    func calculateDistanceOfEachXCatagory(number: Int) -> CGFloat {
        let segmentDivision = CGFloat(number + 2)
        let segment = (xView.bounds.maxX / segmentDivision)
        return segment
    }
    
    // MARK: - XView Setup
    func createXView(time: Int, array: [String]) {
        let segmentDivision = CGFloat(time + 2)
        let segment = (xView.bounds.maxX / segmentDivision)
        var count: CGFloat = 1
        var arrayCount: Int = 0
        for _ in 1...time {
            let x:CGFloat = 1
            let y:CGFloat = 1
            let width = xView.bounds.height
            let height: CGFloat = 15.0
            print (segment, x, y, width, height)
            let frame = CGRect(x: x, y: y, width: width, height: height)
            let label = UILabel(frame: frame)
            label.center = CGPoint(x: (count * segment), y: xView.bounds.midY)
            label.text = array[arrayCount]+"-"
            label.textColor = .black
            label.textAlignment = .right
            label.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
            label.clipsToBounds = true
            xView.addSubview(label)
            count += 1
            arrayCount += 1
        }
    }
    
    // MARK: - YView Setup
    func createYView(totals: [Double]) {
        guard let greatestValue = totals.max() else {return}
        let maxY = yView.bounds.maxY
        let maxYValue = greatestValue + (greatestValue * 0.1)
        let halfGreatestValue = greatestValue/2
        let threeQuatersGreatestValue = greatestValue*3/4
        let quarterGreatestValue = greatestValue/4
        let yGreatestValue = maxY - (calculatePercentValue(withBudgetItemSpentTotal: greatestValue, totalSpent: maxYValue, maxY: maxY))
        let ythreeQuarts = maxY - (calculatePercentValue(withBudgetItemSpentTotal: threeQuatersGreatestValue, totalSpent: maxYValue, maxY: maxY))
        let yHalf = maxY - (calculatePercentValue(withBudgetItemSpentTotal: halfGreatestValue, totalSpent: maxYValue, maxY: maxY))
        let yQuarter = maxY - (calculatePercentValue(withBudgetItemSpentTotal: quarterGreatestValue, totalSpent: maxYValue, maxY: maxY))
        createLabel(withCenterOnPointsX: yView.bounds.midX, y: yGreatestValue, andLabelName: "\(Int(greatestValue))")
        createLabel(withCenterOnPointsX: yView.bounds.midX, y: ythreeQuarts, andLabelName: "\(Int(threeQuatersGreatestValue))")
        createLabel(withCenterOnPointsX: yView.bounds.midX, y: yHalf, andLabelName: "\(Int(halfGreatestValue))")
        createLabel(withCenterOnPointsX: yView.bounds.midX, y: yQuarter, andLabelName: "\(Int(quarterGreatestValue))")
    }
    
    func createLabel(withCenterOnPointsX x: CGFloat , y: CGFloat, andLabelName name: String ){
        let frame = CGRect(x: 1, y: 1, width: yView.bounds.width, height: 21)
        let label = UILabel(frame: frame)
        label.center = CGPoint(x: x, y: y)
        label.text = "$"+name+"-"
        label.textColor = .black
        label.textAlignment = .right
        label.clipsToBounds = true
        yView.addSubview(label)
    }
    
    func calculatePercentValue(withBudgetItemSpentTotal budgetItemSpentTotal: Double, totalSpent: Double, maxY: CGFloat) -> CGFloat {
        let bugetItemCGFloat = CGFloat(budgetItemSpentTotal)
        let totalSpentCGFloat = CGFloat(totalSpent)
        return (bugetItemCGFloat/totalSpentCGFloat) * maxY
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
