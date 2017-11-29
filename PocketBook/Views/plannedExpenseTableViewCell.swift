//
//  plannedExpenseTableViewCell.swift
//  PocketBook
//
//  Created by Laura O'Brien on 11/10/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class plannedExpenseTableViewCell: UITableViewCell {
    
    //MARK: - Outlets
    
    @IBOutlet weak var plannedExpenseNameLabel: UILabel!
    @IBOutlet weak var byDueDateLabel: UILabel!
    @IBOutlet weak var PEProgressBar: UIProgressView!
    @IBOutlet weak var progressBarLabel: UILabel!
    
    
    //MARK: - Properties
    weak var delegate: PlannedExpenseTableViewCellDelegate?
    
    var plannedExpense: PlannedExpense? {
        didSet {
            updateCell(plannedExpense: plannedExpense!)
        }
    }
    
    //MARK: - Functions
    func updateCell(plannedExpense: PlannedExpense) {
        let totalSaved = plannedExpense.totalDeposited + plannedExpense.initialAmount
        plannedExpenseNameLabel.text = plannedExpense.name
        byDueDateLabel.text = returnFormattedDateString(date: plannedExpense.dueDate)
        configureProgressBar(withPlannedExpense: plannedExpense)
        progressBarLabel.text = "\(formatNumberToString(fromDouble: totalSaved)) / \(formatNumberToString(fromDouble: plannedExpense.goalAmount))"
    }
    
    func configureProgressBar(withPlannedExpense plannedExpense: PlannedExpense) {
        self.PEProgressBar.progress = 0
        self.PEProgressBar.progressTintColor = .blue7
        PEProgressBar.transform = CGAffineTransform.init(scaleX: 1, y: 10)
        let totalSaved = plannedExpense.totalDeposited + plannedExpense.initialAmount
        self.PEProgressBar.progress = Float(totalSaved) / Float(plannedExpense.goalAmount)
    }
    
    //Date Formatting
    func returnFormattedDateString(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        let strDate = dateFormatter.string(from: date)
        return strDate
        
    }
}

//MARK: - Cell Delegate Protocol
protocol PlannedExpenseTableViewCellDelegate: class {
    
}

