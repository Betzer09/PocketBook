//
//  LineGraphView.swift
//  PocketBook
//
//  Created by Michael Meyers on 11/8/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

class LineGraphView: UIView {
    
    static let shared = LineGraphView()
    
    var dots: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false // when overriding drawRect, you must specify this to maintain transparency.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createChartLine() {
        let color = UIColor.blue7
        let line = UIBezierPath()
        line.lineWidth = 3
        var count = 0
        for dot in dots {
            let point = dot.center
            if count == 0 {
                line.move(to: point)
                count += 1
            } else {
                line.addLine(to: point)
            }
        }
        color.setStroke()
        line.stroke()
        setNeedsDisplay()
    }
    
    func createXAxis() {
        let color = UIColor.black
        let line = UIBezierPath()
        line.lineWidth = 5
        let point = CGPoint(x: bounds.minX, y: bounds.maxY)
        line.move(to: point)
        let endPoint = CGPoint(x: bounds.maxX, y: bounds.maxY)
        line.addLine(to: endPoint)
        color.setStroke()
        line.stroke()
        setNeedsDisplay()
    }
    
    func createYAxis() {
        let color = UIColor.black
        let line = UIBezierPath()
        line.lineWidth = 5
        let point = CGPoint(x: bounds.minX, y: bounds.maxY)
        line.move(to: point)
        let endPoint = CGPoint(x: bounds.minX, y: bounds.minY)
        line.addLine(to: endPoint)
        color.setStroke()
        line.stroke()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        createChartLine()
        createXAxis()
        createYAxis()
    }
    
    
    // MARK: - Configure Line Graph
    func configureLineGraph(lineGraphView: LineGraphView, xView: UIView, yView: UIView, forTotals totals: [Double], withTimeFrame timeFrame: String, andCategory category: String, viewControllerToPresentAlert viewController: UIViewController) {
        
        dots = []
        xView.subviews.forEach { $0.removeFromSuperview() }
        yView.subviews.forEach { $0.removeFromSuperview() }
        lineGraphView.subviews.forEach { $0.removeFromSuperview() }
        
        var distanceOfEachXCatagory: CGFloat = 0
        var time: Int = 0
        var array: [String] = []
        
        let currentMonth = dateComponentMonth(date: Date())
        
        switch timeFrame {
        case TimeFrame.pastYear.rawValue:
            time = 12
            var count = currentMonth - 1
            while count >= 0 {
                let monthString = monthsOfTheYear[count]
                array.insert(monthString, at: 0)
//                array.append(monthString)
                count -= 1
            }
            count = 11
            while count + 1  > currentMonth {
                let monthString = monthsOfTheYear[count]
                array.insert(monthString, at: 0)
//                array.append(monthString)
                count -= 1
            }
        case TimeFrame.yearToDate.rawValue:
            time = currentMonth
            for month in 1...time {
                let monthString = monthsOfTheYear[month - 1]
                array.append(monthString)
            }
        case TimeFrame.lastMonth.rawValue:
            time = 4
            array = weeksOfTheMonth
        case TimeFrame.thisMonth.rawValue:
            time = 4
            array = weeksOfTheMonth
        default: fatalError()
        }
        distanceOfEachXCatagory = calculateDistanceOfEachXCatagory(inView: xView, withDivisor: time)
        createXView(fromView: xView, time: time, array: array)
        createYView(totals: totals, inView: yView, withViewControllerToPresentAlert: viewController)
        createScatterPlot(inView: lineGraphView, xDistance: distanceOfEachXCatagory, totals: totals)
    }
    
    func calculateTotalsArray(fromTransactions transactions: [Transaction], withTimeFrame timeFrame: String, andCategory category: String) -> [Double] {
        
        var totals: [Double] = []
        
        let currentMonth = dateComponentMonth(date: Date())
        
        switch timeFrame {
        case TimeFrame.pastYear.rawValue:
            var count = currentMonth - 1
            while count >= 0 {
                var total: Double = 0.0
                for transaction in transactions {
                    let month = count + 1
                    let transactionMonth = dateComponentMonth(date: transaction.date)
                    if month == transactionMonth {
                        total += transaction.amount
                    }
                }
                totals.insert(total, at: 0)
//                totals.append(total)
                count -= 1
            }
            count = 11
            while count + 1  > currentMonth {
                var total: Double = 0.0
                for transaction in transactions {
                    let month = count + 1
                    let transactionMonth = dateComponentMonth(date: transaction.date)
                    if month == transactionMonth {
                        total += transaction.amount
                    }
                }
                totals.insert(total, at: 0)
//                totals.append(total)
                count -= 1
            }
        case TimeFrame.yearToDate.rawValue:
            for month in 1...currentMonth {
                var total: Double = 0.0
                for transaction in transactions {
                    let transactionMonth = dateComponentMonth(date: transaction.date)
                    if month == transactionMonth {
                        total += transaction.amount
                    }
                }
                totals.append(total)
            }
        case TimeFrame.lastMonth.rawValue:
            let lastMonth = currentMonth - 1
            totals = calculateMonthTotals(transactions: transactions, month: lastMonth)
        case TimeFrame.thisMonth.rawValue:
            totals = calculateMonthTotals(transactions: transactions, month: currentMonth)
        default: fatalError()
        }
        return totals
    }
    
    // MARK: - LineGraphView Setup
    func createDot(inView lineGraphView: LineGraphView, withCoordinatesX x: CGFloat, y: CGFloat) -> UIView {
        let dot = UIView()
        let originY = (lineGraphView.bounds.maxY - y)
        dot.frame = CGRect(x: x, y: originY, width: 7, height: 7)
        dot.backgroundColor = .blue13
        lineGraphView.addSubview(dot)
        return dot
    }
    
    func createScatterPlot(inView lineGraphView: LineGraphView, xDistance: CGFloat, totals: [Double]) {
        var segmentCount: CGFloat = 1
        var dots: [UIView] = []
        for total in totals {
            guard let maxTotal = totals.max() else {return}
            let totals = maxTotal + (maxTotal * 0.1)
            let cgFloatTotal = calculatePercentValue(withBudgetItemSpentTotal: total, totalSpent:totals , maxY: lineGraphView.bounds.maxY)
            if total == 0.0 {
                let dot = createDot(inView: lineGraphView, withCoordinatesX: segmentCount * xDistance, y: 15)
                dots.append(dot)
            } else {
                let dot = createDot(inView: lineGraphView, withCoordinatesX: segmentCount * xDistance, y:cgFloatTotal )
                dots.append(dot)
            }
            segmentCount += 1
        }
        lineGraphView.dots = dots
        lineGraphView.setNeedsDisplay()
    }
    
    // MARK: - XView Setup
    func createXView(fromView xView: UIView, time: Int, array: [String]) {
        let segmentDivision = CGFloat(time + 2)
        let segment = (xView.bounds.maxX / segmentDivision)
        var count: CGFloat = 1
        var arrayCount: Int = 0
        for _ in 1...time {
            let x:CGFloat = 1
            let y:CGFloat = 1
            let width = xView.bounds.height
            let height: CGFloat = 15.0
            //            print (segment, x, y, width, height)
            let frame = CGRect(x: x, y: y, width: width, height: height)
            let label = UILabel(frame: frame)
            label.center = CGPoint(x: (count * segment), y: xView.bounds.midY)
            label.text = array[arrayCount]+"-"
            label.textColor = .black
            label.font = UIFont(name: Keys.avenirNext, size: label.font.pointSize)
            label.textAlignment = .right
            label.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
            label.clipsToBounds = true
            xView.addSubview(label)
            count += 1
            arrayCount += 1
        }
    }
    
    // MARK: - YView Setup
    func createYView(totals: [Double], inView yView: UIView, withViewControllerToPresentAlert viewController: UIViewController) {
        guard let greatestValue = totals.max(), greatestValue != 0 else {return}
        let maxY = yView.bounds.maxY
        let maxYValue = greatestValue + (greatestValue * 0.1)
        let halfGreatestValue = greatestValue/2
        let threeQuatersGreatestValue = greatestValue*3/4
        let quarterGreatestValue = greatestValue/4
        let yGreatestValue = maxY - (calculatePercentValue(withBudgetItemSpentTotal: greatestValue, totalSpent: maxYValue, maxY: maxY))
        let ythreeQuarts = maxY - (calculatePercentValue(withBudgetItemSpentTotal: threeQuatersGreatestValue, totalSpent: maxYValue, maxY: maxY))
        let yHalf = maxY - (calculatePercentValue(withBudgetItemSpentTotal: halfGreatestValue, totalSpent: maxYValue, maxY: maxY))
        let yQuarter = maxY - (calculatePercentValue(withBudgetItemSpentTotal: quarterGreatestValue, totalSpent: maxYValue, maxY: maxY))
        createLabel(inView: yView, withCenterOnPointsX: yView.bounds.midX, y: yGreatestValue, andLabelName: "\(Int(greatestValue))")
        createLabel(inView: yView, withCenterOnPointsX: yView.bounds.midX, y: ythreeQuarts, andLabelName: "\(Int(threeQuatersGreatestValue))")
        createLabel(inView: yView, withCenterOnPointsX: yView.bounds.midX, y: yHalf, andLabelName: "\(Int(halfGreatestValue))")
        createLabel(inView: yView, withCenterOnPointsX: yView.bounds.midX, y: yQuarter, andLabelName: "\(Int(quarterGreatestValue))")
    }
    
    func createLabel(inView view: UIView, withCenterOnPointsX x: CGFloat , y: CGFloat, andLabelName name: String ){
        let frame = CGRect(x: 1, y: 1, width: view.bounds.width, height: 21)
        let label = UILabel(frame: frame)
        label.center = CGPoint(x: x, y: y)
        label.font = UIFont(name: Keys.avenirNext, size: label.font.pointSize)
        label.text = "$"+name+"-"
        label.textColor = .black
        label.textAlignment = .right
        label.clipsToBounds = true
        view.addSubview(label)
    }
}
