//
//  OverviewTableViewController.swift
//  PocketBook
//
//  Created by Austin Betzer on 11/7/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//


//NOTE: tableView cells are called "accountCell"
//NOTE: plus button to AccountDetailsVC segue is called "toAccountDetails"

import UIKit

class OverviewTableViewController: UITableViewController {
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkToSeeIfTheTableViewNeedsUpdated()

    }

    // MARK: - Actions

    
    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AccountController.shared.accounts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath)
        
        let account = AccountController.shared.accounts[indexPath.row]
        cell.textLabel?.text = account.name
        cell.detailTextLabel?.text = account.accountType
        
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            let account = AccountController.shared.accounts[indexPath.row]
            AccountController.shared.delete(account: account)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Methods
    
    func checkToSeeIfTheTableViewNeedsUpdated() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: AccountController.shared.accountsWhereUpdatedNotification, object: nil)
        
        // When the view has loaded fetch the Accounts
        AccountController.shared.fetchAccountsFromCloudKit()
        
    }
    
    @objc func reloadTableView() {
        DispatchQueue.main.async {
         self.tableView.reloadData()
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toAccountDetails" {
            
            guard let destinationVC = segue.destination as? AccountDetailsViewController, let indexPath = tableView.indexPathForSelectedRow else {return}
            
            destinationVC.account = AccountController.shared.accounts[indexPath.row]
        }
    }

}
















