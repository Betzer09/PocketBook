//
//  TransactionTableViewCell.swift
//  PocketBook
//
//  Created by Brian Weissberg on 11/8/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // This function formats the way that the date appears in the tableView
    func returnFormattedDateString() -> String {
        
        guard let date = transactions?.date else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let transactionDate = dateFormatter.string(from: date)
        return transactionDate
        
    }
    
    private func updateViews() {
        
        guard let transactions = transactions else { return }
        self.payeeLabel.text = transactions.payee
        self.dateLabel.text = "\(returnFormattedDateString())"
        self.amountLabel.text = "\(String(format: "$%.02f", transactions.amount))"
        
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
