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
        plannedExpenseNameLabel.text = plannedExpense.name
        byDueDateLabel.text = "\(plannedExpense.dueDate)"
        PEProgressBar.progress = Float(plannedExpense.totalSaved!)
    }
    
    func configureProgressBar(withPlannedExpense plannedExpense: PlannedExpense) {
        self.PEProgressBar.progress = 0
        self.PEProgressBar.progressTintColor = .blue
        PEProgressBar.transform = CGAffineTransform.init(scaleX: 1, y: 10)
        
        self.PEProgressBar.progress = Float(plannedExpense.totalSaved!) / Float(plannedExpense.goalAmount)
    }
}

//MARK: - Cell Delegate Protocol
protocol PlannedExpenseTableViewCellDelegate: class {
    
}

