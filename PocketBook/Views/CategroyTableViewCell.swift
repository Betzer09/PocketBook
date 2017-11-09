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
    
    func updateCell(budgetItem: BudgetItem) {
        categoryNameLabel.text = budgetItem.name
    }

}
