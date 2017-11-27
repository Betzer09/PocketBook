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
        progressBarDescriptionLabel.text = "\(formatNumberToString(fromDouble: budgetItem.spentTotal)) / \(formatNumberToString(fromDouble: totalAlloted))"
    }
    
    func configureProgressBar(withBudgetItem budgetItem: BudgetItem ) {
        self.progressBar.progress = 0
        self.progressBar.progressTintColor = UIColor(red: 167 / 255.0, green: 233 / 255.0, blue: 253 / 255.0, alpha: 1)
        progressBar.transform = CGAffineTransform.init(scaleX: 1, y: 10)
        self.progressBar.progress = Float(budgetItem.spentTotal) / Float(budgetItem.allottedAmount)
    }
    
}