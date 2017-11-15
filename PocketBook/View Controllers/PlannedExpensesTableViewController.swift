//
//  PlannedExpensesTableViewController.swift
//  PocketBook
//
//  Created by Laura O'Brien on 11/6/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit


//>> Needs a cell delegate?? <<
//Need a way to calculate totalSaved where? model controller?
//    let totalSaved = initialAmount + add button amounts??

class PlannedExpensesTableViewController: UITableViewController, PlannedExpenseTableViewCellDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var totalIdealMonthlyContributionLabel: UILabel!
    
    //MARK: ??????
    //MARK: - Properties
    var plannedExpense: PlannedExpense? {
        didSet {
            if isViewLoaded { updateViews() }
        }
    }
    
    //MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
        updateViews()
    }
    
    //MARK: - Functions
    private func updateViews() {
//        guard let plannedExpense = plannedExpense else { return }
        // MARK: - ??????
//         totalIdealMonthlyContributionLabel.text = plannedExpense
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PlannedExpenseController.shared.plannedExpenses.count
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

