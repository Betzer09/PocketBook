//
//  TransactionTableViewCell.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/7/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // This function formats the way that the date appears in the tableView
    
    private func updateViews() {
        
        guard let transactions = transactions else { return }
        self.payeeLabel.text = transactions.payee.lowercased().capitalized
        self.dateLabel.text = returnFormattedDate(fromdate: transactions.date)
        if transactions.transactionType == TransactionType.income.rawValue {
            self.amountLabel.text = "+ \(formatNumberToString(fromDouble: transactions.amount))"
        } else {
            self.amountLabel.text = "- \(formatNumberToString(fromDouble: transactions.amount))"

        }
    }
    
    var transactions: Transaction? {
        didSet {
            self.updateViews()
        }
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var payeeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
}

