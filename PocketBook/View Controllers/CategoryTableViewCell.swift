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
        categoryNameLabel.text = budgetItem.name.lowercased().capitalized
        configureProgressBar(withBudgetItem: budgetItem)
        let total = decideWhichTotalToUseWith(budgetItem: budgetItem)
        progressBarDescriptionLabel.text = "\(formatNumberToString(fromDouble: budgetItem.spentTotal)) / \(formatNumberToString(fromDouble: total))"
    }
    
    func configureProgressBar(withBudgetItem budgetItem: BudgetItem ) {
        self.progressBar.progress = 0
        self.progressBar.progressTintColor = .blue3
        progressBar.transform = CGAffineTransform.init(scaleX: 1, y: 10)
        let total = decideWhichTotalToUseWith(budgetItem: budgetItem)
        self.progressBar.progress = Float(budgetItem.spentTotal) / Float(total)
    }
    
    func decideWhichTotalToUseWith(budgetItem: BudgetItem) -> Double {
        guard let totalAllotted = budgetItem.totalAllotted else {fatalError()}
        var total = budgetItem.allottedAmount
        if totalAllotted > budgetItem.allottedAmount{
            total = totalAllotted
        }
        return total
    }
        
}
