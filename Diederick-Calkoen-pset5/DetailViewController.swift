//
//  DetailViewController.swift
//  Diederick-Calkoen-pset5
//
//  Created by Diederick Calkoen on 29/11/16.
//  Copyright © 2016 Diederick Calkoen. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    private let db = DatabaseHelper()
    
    var idCurrentList = Int64()
    var nameCurrentList = String()

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputDataField: UITextField!

    
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        idCurrentList = getId(name: nameCurrentList)
        self.loadToDo(id: idCurrentList)
        self.configureView()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func AddToDo(_ sender: Any) {
        toDoAdding()
    }
    @IBAction func enterPressed(_ sender: Any) {
        toDoAdding()
    }
    
    // MARK: - Fuctions
    func loadToDo(id: Int64) {
        do {
            globalArrays.detailArray = try db!.read(idList: idCurrentList)
        } catch {
            print(error)
        }
    }
    
    func getId(name: String) -> Int64 {
        var id = Int64()
        id =  db!.getListId(listName: name)
        return id
    }
    
    func toDoAdding() {
        if inputDataField.text == "" {
            let alertController = UIAlertController(title: "No input provided", message:
                "Enter a to-do to add to the list.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            return
        }
        else {
            do {
                try db!.createToDo(ToDo: inputDataField.text!, listId: idCurrentList)
            } catch {
                print(error)
            }
            loadToDo(id: idCurrentList)
            inputDataField.text = ""
            tableView.reloadData()
        }
    }
}

// MARK: - Table View
extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return globalArrays.detailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomCell
        let db = DatabaseHelper()
        var status = Bool()
        do {
            status = try db!.getStatus(toDoName: globalArrays.detailArray[indexPath.row])
        } catch {
            print(error)
        }
        if status == false {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        cell.detialToDoLabel.text = (globalArrays.detailArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let db = DatabaseHelper()
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        var status = Bool()
        do {
            status = try db!.getStatus(toDoName: globalArrays.detailArray[indexPath.row])
            print(status)
            try db!.changeBool(item: globalArrays.detailArray[indexPath.row], value: !status)
            status = try db!.getStatus(toDoName: globalArrays.detailArray[indexPath.row])
            print(status)
            loadToDo(id: idCurrentList)
        } catch {
            print(error)
        }
        status = !status
        if status == false {
            cell?.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell?.accessoryType = UITableViewCellAccessoryType.none
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let db = DatabaseHelper()
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            let current = globalArrays.detailArray[indexPath.row]
            
            do {
                try db!.deleteToDo(id: idCurrentList, toDoName: current)
            } catch {
                print(error)
            }
            self.loadToDo(id: idCurrentList)
            print(globalArrays.listArray)
            self.loadView()
            tableView.reloadData()
        }
    }
}
