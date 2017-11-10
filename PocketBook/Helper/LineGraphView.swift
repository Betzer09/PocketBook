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
    var dots: [UIView]?
    var maxX: CGFloat?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createChartLine() {
        guard let dots = dots else {return}
        let color = UIColor.green
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
}
