//
//  CategroyTableViewCell.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/9/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class CategroyTableViewCell: UITableViewCell {
    
    
    // MARK: - Outlets
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressBarDescriptionLabel: UILabel!
    
    func updateCell(budgetItem: BudgetItem) {
        guard let totalAlloted = budgetItem.totalAllotted else {return}
        categoryNameLabel.text = budgetItem.name
        configureProgressBar(withBudgetItem: budgetItem)
        progressBarDescriptionLabel.text = "$\(budgetItem.spentTotal) / $\(totalAlloted)"
    }
    
    func configureProgressBar(withBudgetItem budgetItem: BudgetItem ) {
        self.progressBar.progress = 0
        self.progressBar.progressTintColor = .red
        progressBar.transform = CGAffineTransform.init(scaleX: 1, y: 10)
        // This is just for testing purposes 
        //        self.progressBar.progress = Float(10) / Float(budgetItem.allottedAmount)
        self.progressBar.progress = Float(budgetItem.spentTotal) / Float(budgetItem.allottedAmount)
    }
    
}
