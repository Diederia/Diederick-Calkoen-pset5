//
//  MasterViewController.swift
//  Diederick-Calkoen-pset5
//
//  Created by Diederick Calkoen on 29/11/16.
//  Copyright © 2016 Diederick Calkoen. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    
    private let db = DatabaseHelper()

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // load data from database in list
        if db == nil{
            print("Error")
        }
        loadList()
        tableView.reloadData()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewList(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Functions
    func insertNewList(_ sender: Any) {
        let alert = UIAlertController(title: "Add a list", message: "Please insert the name of the list", preferredStyle: .alert)
        alert.addTextField { (inputField) in
            inputField.text = ""
            inputField.placeholder = "Enter a list"
        }
        alert.addAction(UIAlertAction(title: "Add list", style: .default, handler: { (_) in
            let inputField = alert.textFields![0] as UITextField
            if inputField.text != "" {
                if globalArrays.listArray.contains(inputField.text!) {
                    print("Please enter a new list to add")
                } else {
                    self.createNewList(tableName: inputField.text!)
                    self.loadList()
                    self.tableView.reloadData()
                    inputField.text = ""
                }
            } else {
                print("Please, enter first a title to add")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
                
    func createNewList(tableName: String) {
        do {
            try self.db?.createList(name: tableName)
        } catch {
            print(error)
        }
    }
    
    func loadList() {
        do {
            globalArrays.listArray = try db!.getLists()!
        } catch {
            print(error)
        }
    }
    
    func getIdList(name: String) -> Int64 {
        var id = Int64()
        id = db!.getListId(listName: name)
        return id
    }
    
    func deleteList(id: Int64, listName: String) {
        do {
            try db!.deleteList(id: id, listName: listName)
            self.loadList()
            self.tableView.reloadData()
        } catch {
            print(error)
        }
    }

    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = globalArrays.listArray[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.nameCurrentList = object
                controller.detailItem = (object as AnyObject!)
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return globalArrays.listArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        loadList()
        let object = globalArrays.listArray[indexPath.row]
        cell.textLabel!.text = object.description
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteList(id: getIdList(name: globalArrays.listArray[indexPath.row]), listName: globalArrays.listArray[indexPath.row])
            loadList()
            tableView.reloadData()
        }
    }
}

