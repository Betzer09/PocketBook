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
    
    //MARK: - Properties
    weak var delegate: PlannedExpenseTableViewCellDelegate?
    
    var plannedExpense: PlannedExpense? {
        didSet {
            updateViews()
        }
    }
    
    //MARK: - Functions
    func updateViews() {
        guard let plannedExpense = plannedExpense else { return }
        
        plannedExpenseNameLabel.text = plannedExpense.name
        byDueDateLabel.text = "\(plannedExpense.dueDate)"
        PEProgressBar.progress = Float(plannedExpense.totalSaved)
    }
}

//MARK: - Cell Delegate Protocol
protocol PlannedExpenseTableViewCellDelegate: class {
    
}

