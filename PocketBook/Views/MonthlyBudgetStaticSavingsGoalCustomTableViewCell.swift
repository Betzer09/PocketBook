//
//  MonthlyBudgetStaticSavingsGoalCustomTableViewCell.swift
//  PocketBook
//
//  Created by Laura O'Brien on 12/1/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class MonthlyBudgetStaticSavingsGoalCustomTableViewCell: UITableViewCell {

    
    // MARK: - Outlets
    @IBOutlet weak var savingsGoalLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressBarDescriptionLabel: UILabel!
    
    func updateCell() {
        savingsGoalLabel.text = "Savings Goals"
        configureProgressBar()
        progressBarDescriptionLabel.text = "\(formatNumberToString(fromDouble: PlannedExpenseController.shared.addUpTotalDepositedToSavings())) / \(formatNumberToString(fromDouble: PlannedExpenseController.shared.calculateTotalMonthlyContribution()))"
    }
    
    func configureProgressBar() {
        self.progressBar.progress = 0
        self.progressBar.progressTintColor = .blue7
        progressBar.transform = CGAffineTransform.init(scaleX: 1, y: 10)
        self.progressBar.progress = Float(PlannedExpenseController.shared.addUpTotalDepositedToSavings()) / Float(PlannedExpenseController.shared.calculateTotalMonthlyContribution())
    }
    
}
