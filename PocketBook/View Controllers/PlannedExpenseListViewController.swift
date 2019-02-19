//
//  PlannedExpenseListViewController.swift
//  PocketBook
//
//  Created by Michael Meyers on 11/30/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class PlannedExpenseListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PlannedExpenseTableViewCellDelegate {

    
    //MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalIdealMonthlyContributionLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var noDataImage: UIImageView!
    
    //MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        setupNotificationObservers()
        createPlusButton()
        changeCalculatedContributionlabel()
        configureNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        noDataImageSetup()
        updateViews()
    }
    
    // MARK: - Actions
    @IBAction func unwindToPlannedExpenseViewController(unwindSegue: UIStoryboardSegue) {
        if let _ = unwindSegue.source as? PlannedExpenseDetailViewController {
            print("Coming from plannedExpnsesVC")
        }
    }
    
    //MARK: - Functions
    
    func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateViews), name: Notifications.plannedExpenseWasUpdatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeCalculatedContributionlabel), name: Notifications.plannedExpenseWasUpdatedNotification, object: nil)
    }
    
    func noDataImageSetup() {
        let plannedExpense = PlannedExpenseController.shared.plannedExpenses
        
        DispatchQueue.main.async {
            if plannedExpense.count == 0 {
                self.noDataImage.isHidden = false
            } else {
                self.noDataImage.isHidden = true
            }
        }
        
    }
    
    func setDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func configureNavigationBar() {
        guard let font = UIFont(name: "Avenir Next", size: 17) else {return}
        let attributes = [ NSAttributedString.Key.font: font,
                           NSAttributedString.Key.foregroundColor : UIColor.white,
                           ]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.navigationItem.title = self.navigationItem.title
    }
    
    @objc func updateViews() {
        self.noDataImageSetup()
        let totalMonthlyContribution = PlannedExpenseController.shared.calculateTotalMonthlyContribution()
        DispatchQueue.main.async {
            if totalMonthlyContribution <= 0.0 {
                self.amountLabel.text = "\("$0.00")"
                
            } else {
                self.amountLabel.text = "\(formatNumberToString(fromDouble: totalMonthlyContribution))"
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()            
        }
    }
    
    func createPlusButton() {
        let button = UIButton()
        button.clipsToBounds = true
        button.setImage(#imageLiteral(resourceName: "plusButton"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(segueToDetailVC), for: UIControl.Event.touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func segueToDetailVC() {
        if AccountController.shared.accounts.count >= 1 {
            self.performSegue(withIdentifier: "toPersistedPlannedExpenseSegue", sender: self)
        } else {
            presentSimpleAlert(controllerToPresentAlert: self, title: "Create Accounts", message: "Before you can create any Savings Goals you need to add an account first.")
        }
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PlannedExpenseController.shared.plannedExpenses.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "plannedExpenseCell", for: indexPath) as? plannedExpenseTableViewCell else { return UITableViewCell() }
        
        let plannedExpense = PlannedExpenseController.shared.plannedExpenses[indexPath.row]
        
        cell.plannedExpense = plannedExpense
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let plannedExpense = PlannedExpenseController.shared.plannedExpenses[indexPath.row]
            confirmSavingsGoalDeletion(plannedexpense: plannedExpense) { (responce) in
                PlannedExpenseController.shared.delete(plannedExpense: plannedExpense)
                
                PlannedExpenseController.shared.plannedExpenses.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            }
            
        }
    }
    
    // MARK: - Methods
    
    func confirmSavingsGoalDeletion(plannedexpense: PlannedExpense, completion: @escaping (_ responce: Bool) -> Void) {
        let alert = UIAlertController(title: "Delete \(plannedexpense.name)?", message: "Are you sure you want to delete your Savings Goal? Everything you have contribued will go back into your account.", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            completion(true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            completion(false)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    /// This function changes the calculatedContributionLabel text if there aren't any savings goals
    @objc func changeCalculatedContributionlabel() {
        DispatchQueue.main.async {
            self.amountLabel.isHidden = false
            self.totalIdealMonthlyContributionLabel.text = "Total Ideal Monthly Contribution:"
            self.totalIdealMonthlyContributionLabel.textColor = .black
            self.totalIdealMonthlyContributionLabel.textAlignment = .left
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPersistedPlannedExpenseSegue" {
            guard let destinationVC = segue.destination as? PlannedExpenseDetailViewController, let indexPath = tableView.indexPathForSelectedRow else { return }
            let plannedExpense = PlannedExpenseController.shared.plannedExpenses[indexPath.row]
            destinationVC.plannedExpense = plannedExpense
        }
    }

}
