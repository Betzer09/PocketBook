//
//  AccountTableViewController.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/7/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//


//NOTE: tableView cells are called "accountCell"
//NOTE: plus button to AccountDetailsVC segue is called "toAccountDetails"

import UIKit

class AccountTableViewController: UITableViewController {
    
    // MARK: - View LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: Notifications.accountWasUpdatedNotification, object: nil)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AccountController.shared.accounts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath)
        
        let account = AccountController.shared.accounts[indexPath.row]
        cell.textLabel?.text = account.name
        
        let stringAmount = String(format: "$%.2f", account.total)        
        cell.detailTextLabel?.text = stringAmount
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            let account = AccountController.shared.accounts[indexPath.row]
            AccountController.shared.accounts.remove(at: indexPath.row)
            AccountController.shared.delete(account: account)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // When an account is deleted, delete all corresponding transactions
            for transaction in TransactionController.shared.transactions {
                if transaction.account == account.name {
                    let updatedTransactions = TransactionController.shared.transactions.filter { $0.account != account.name }
                    TransactionController.shared.transactions = updatedTransactions
                    TransactionController.shared.delete(transaction: transaction)
                }
            }
            
            // FIXME: Use similiar logic as above to delete all planned expenses when an account is deleted
       
            // FIXME: Present alert for the user to make sure that they want to delete an account
        }
    }

    // MARK: - All Methods
    @objc func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
        
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toAccountDetail" {
            
            guard let destinationVC = segue.destination as? AccountDetailsViewController, let indexPath = tableView.indexPathForSelectedRow else {return}
            
            destinationVC.account = AccountController.shared.accounts[indexPath.row]
        }
    }
}
















