//
//  PlannedExpensesTableViewController.swift
//  PocketBook
//
//  Created by Laura O'Brien on 11/6/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class PlannedExpensesTableViewController: UITableViewController, PlannedExpenseTableViewCellDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var totalIdealMonthlyContributionLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    //MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        createPlusButton()
        changeCalculatedContributionlabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateViews), name: Notifications.plannedExpenseWasUpdatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeCalculatedContributionlabel), name: Notifications.plannedExpenseWasUpdatedNotification, object: nil)
    }
    
    //MARK: - Functions
    @objc func updateViews() {
        let totalMonthlyContribution = PlannedExpenseController.shared.calculateTotalMonthlyContribution()
        if totalMonthlyContribution <= 0.0 {
            amountLabel.text = "\("$0.00")"
        } else {
            amountLabel.text = "\(formatNumberToString(fromDouble: totalMonthlyContribution))"
        }
    }
    
    func createPlusButton() {
        let button = UIButton()
        button.clipsToBounds = true
        button.setImage(#imageLiteral(resourceName: "plusButton"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(segueToDetailVC), for: UIControlEvents.touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func segueToDetailVC() {
        self.performSegue(withIdentifier: "toPersistedPlannedExpenseSegue", sender: self)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PlannedExpenseController.shared.plannedExpenses.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "plannedExpenseCell", for: indexPath) as? plannedExpenseTableViewCell else { return UITableViewCell() }
        
        let plannedExpense = PlannedExpenseController.shared.plannedExpenses[indexPath.row]
        
        cell.plannedExpense = plannedExpense
        cell.delegate = self
        
        return cell
    }
    
    // >>Ability to Delete Cells
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let plannedExpense = PlannedExpenseController.shared.plannedExpenses[indexPath.row]
            PlannedExpenseController.shared.delete(plannedExpense: plannedExpense)
            PlannedExpenseController.shared.plannedExpenses.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - Methods
    
    /// This function changes the calculatedContributionLabel text if there aren't any savings goals
    @objc func changeCalculatedContributionlabel() {
        if PlannedExpenseController.shared.plannedExpenses.count == 0 {
            totalIdealMonthlyContributionLabel.text = "Let's create some savings goals!"
            totalIdealMonthlyContributionLabel.textColor = .gray
            totalIdealMonthlyContributionLabel.textAlignment = .center
            amountLabel.isHidden = true
        } else {
            amountLabel.isHidden = false
            totalIdealMonthlyContributionLabel.text = "Total Ideal Monthly Contribution:"
            totalIdealMonthlyContributionLabel.textColor = .black
            totalIdealMonthlyContributionLabel.textAlignment = .left
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPersistedPlannedExpenseSegue" {
            guard let destinationVC = segue.destination as? PlannedExpenseViewController, let indexPath = tableView.indexPathForSelectedRow else { return }
            let plannedExpense = PlannedExpenseController.shared.plannedExpenses[indexPath.row]
            destinationVC.plannedExpense = plannedExpense
        }
    }
}

