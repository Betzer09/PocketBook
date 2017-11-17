//
//  PlannedExpensesTableViewController.swift
//  PocketBook
//
//  Created by Laura O'Brien on 11/6/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit


//>> Needs a cell delegate?? Or no? <<

class PlannedExpensesTableViewController: UITableViewController, PlannedExpenseTableViewCellDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var totalIdealMonthlyContributionLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    //MARK: - Properties
//    var plannedExpense: PlannedExpense? {
//        didSet {
//            if isViewLoaded { updateViews() }
//        }
//    }
    
    //MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        amountLabel.text = "\(formatNumberToString(fromDouble: PlannedExpenseController.shared.calculateTotalMonthlyContribution()))"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
        updateViews()
        amountLabel.text = "\(formatNumberToString(fromDouble: PlannedExpenseController.shared.calculateTotalMonthlyContribution()))"
    }
    
    //MARK: - Functions
    private func updateViews() {
//        guard let plannedExpense = plannedExpense else { return }
//         totalIdealMonthlyContributionLabel.text = plannedExpense
        
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
            
            tableView.deleteRows(at: [indexPath], with: .fade)
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

