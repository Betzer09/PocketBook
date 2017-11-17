//
//  PieChartView.swift
//  PocketBook
//
//  Created by Michael Meyers on 11/8/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import CoreGraphics
import UIKit


class PieChartView: UIView {
    
    static let shared = PieChartView()
    
    /// An array of structs representing the segments of the pie chart
    var segments = [Segment]() {
        didSet {
            setNeedsDisplay() // re-draw view when the values get set
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false // when overriding drawRect, you must specify this to maintain transparency.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        // get current context
        let ctx = UIGraphicsGetCurrentContext()
        let border = UIBezierPath()
        border.lineWidth = 2
        let color = UIColor.white
        
        // radius is the half the frame's width or height (whichever is smallest)
        let radius = min(frame.size.width, frame.size.height) * 0.5
        
        // center of the view
        let viewCenter = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
        
        // enumerate the total value of the segments by using reduce to sum them
        let valueCount = segments.reduce(0, {$0 + $1.value})
        
        // the starting angle is -90 degrees (top of the circle, as the context is flipped). By default, 0 is the right hand side of the circle, with the positive angle being in an anti-clockwise direction (same as a unit circle in maths).
        var startAngle = -CGFloat.pi * 0.5
        
        for segment in segments { // loop through the values array
            
            // set fill color to the segment color
            ctx?.setFillColor(segment.color.cgColor)
            
            // update the end angle of the segment
            let endAngle = startAngle + 2 * .pi * (segment.value / valueCount)
            
            // move to the center of the pie chart
            ctx?.move(to: viewCenter)
            
            // add arc from the center for each segment (anticlockwise is specified for the arc, but as the view flips the context, it will produce a clockwise arc)
            ctx?.addArc(center: viewCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            
            // fill segment
            ctx?.fillPath()
            
            // Adding Border
            border.move(to: viewCenter)
            border.addArc(withCenter: viewCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            color.setStroke()
            border.stroke()
            
            // update starting angle of the next segment to the ending angle of this segment
            startAngle = endAngle
        }
    }
    
    
    // MARK: - LEGEND AND PIE CHART
    
    // MARK: - Legend View
    func createLegendView(fromView legendView: UIView) {
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
        
        createNameAndColorStacks(inSuperView: stackView1, withFrame: frame)
        createNameAndColorStacks(inSuperView: stackView2, withFrame: frame)
    }
    
    func configureStackView(stackView: UIStackView, distribution: UIStackViewDistribution) {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8.0
        stackView.distribution = distribution
    }
    
    func createNameAndColorStacks(inSuperView stackView: UIStackView, withFrame frame: CGRect) {
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
    func formatPieChartViewAndLegend(withPieCharView pieChartView: PieChartView, andLegendView legendView: UIView, usingFilteredDictionary dictionary: [String:Double]){
        guard let nameStackView = legendView.subviews[0].subviews[0].subviews[0] as? UIStackView,
            let colorStackView = legendView.subviews[0].subviews[0].subviews[1] as? UIStackView,
            let nameStackView2 = legendView.subviews[0].subviews[1].subviews[0] as? UIStackView,
            let colorStackView2 = legendView.subviews[0].subviews[1].subviews[1] as? UIStackView else {return}
        nameStackView.subviews.forEach { $0.removeFromSuperview() }
        colorStackView.subviews.forEach{ $0.removeFromSuperview() }
        nameStackView2.subviews.forEach { $0.removeFromSuperview() }
        colorStackView2.subviews.forEach{ $0.removeFromSuperview() }
        
        var segments: [Segment] = []
        var count = 0
        
        let categories = getAllBudgetItemNames()
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
    func formatInnerCircle(fromPieChartView whiteCircle: PieChartView ) {
        let segments = [
            Segment(color: .white, value: 1)
        ]
        whiteCircle.segments = segments
        whiteCircle.backgroundColor = .clear
    }
}

struct Segment {
    
    // the color of a given segment
    var color: UIColor
    
    // the value of a given segment – will be used to automatically calculate a ratio
    var value: CGFloat
}





