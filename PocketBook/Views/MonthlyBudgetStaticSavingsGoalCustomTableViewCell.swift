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
    
    func updateCell(plannedExpense: PlannedExpense) {
        savingsGoalLabel.text = "Savings Goals"
        configureProgressBar(withPlannedExpense: plannedExpense)
        progressBarDescriptionLabel.text = "\(formatNumberToString(fromDouble: plannedExpense.totalDeposited)) / \(formatNumberToString(fromDouble: PlannedExpenseController.shared.calculateTotalMonthlyContribution()))"
    }
    
    func configureProgressBar(withPlannedExpense plannedExpense: PlannedExpense) {
        self.progressBar.progress = 0
        self.progressBar.progressTintColor = .blue7
        progressBar.transform = CGAffineTransform.init(scaleX: 1, y: 10)
        self.progressBar.progress = Float(plannedExpense.totalDeposited) / Float(PlannedExpenseController.shared.calculateTotalMonthlyContribution())
    }
    
}
