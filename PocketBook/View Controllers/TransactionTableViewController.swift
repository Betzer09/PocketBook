//
//  TransactionTableViewController.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/8/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class TransactionTableViewController: UITableViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: Actions
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TransactionController.shared.transactions.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath) as? TransactionTableViewCell ?? TransactionTableViewCell()
        
        cell.transactions = TransactionController.shared.transactions[indexPath.row]
        
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let transaction = TransactionController.shared.transactions[indexPath.row]
            TransactionController.shared.delete(transaction: transaction)
            
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toTransactionDVC" {
            
            guard let destinationVC = segue.destination as? TransactionsDetailViewController,
                let indexPath = tableView.indexPathForSelectedRow else { return }
            let transaction = TransactionController.shared.transactions[indexPath.row]
            
            destinationVC.transaction = transaction
        }
    }
}

