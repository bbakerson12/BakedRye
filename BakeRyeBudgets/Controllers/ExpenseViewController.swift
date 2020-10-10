//
//  ExpenseViewController.swift
//  BakeRyeBudgets
//
//  Created by Alex Baker on 10/9/20.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ExpenseViewController: SwipeTableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var budgetItems: Results<Expense>?
    let realm = try! Realm()
    var selectedCategory: Category? {
        didSet {
            loadExpenses()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colourHex = selectedCategory?.colour {
            title = selectedCategory!.name
            guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.")}
            if let navBarColour = UIColor(hexString: colourHex) {
                navBar.backgroundColor = navBarColour
                navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
                searchBar.barTintColor = navBarColour
            }
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return budgetItems?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let expense = budgetItems?[indexPath.row] {
            cell.textLabel?.text = expense.title
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(budgetItems!.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let expense = budgetItems?[indexPath.row] {
            do{
                try realm.write{
                    expense.done = !expense.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Expense", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Expense", style: .default) { (action) in
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newExpense = Expense()
                        newExpense.title = textField.text!
                        newExpense.dateCreated = Date()
                        currentCategory.expenses.append(newExpense)
                    }
                } catch {
                    print("Error saving new Expense, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new expense"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manipulation Methods
    
    func loadExpenses() {
        budgetItems = selectedCategory?.expenses.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let expense = budgetItems?[indexPath.row] {
            do {
                try realm.write{
                    realm.delete(expense)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
        }
    }
    
}
//MARK: - Searchbar delegate methods
extension ExpenseViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        budgetItems = budgetItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadExpenses()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
