//
//  DatabaseHelper.swift
//  Diederick-Calkoen-pset5
//
//  Created by Diederick Calkoen on 29/11/16.
//  Copyright © 2016 Diederick Calkoen. All rights reserved.
//

import Foundation
import SQLite

struct globalArrays {
    static var listArray = Array<String>()
    static var detailArray = Array<String>()
}

class DatabaseHelper {
    
    private let listTable = Table("listTable")
    private let detailTable = Table("detailTable")
    private let id = Expression<Int64>("id")
    private let toDo = Expression<String?>("toDo")
    private let state = Expression<Bool>("state")
    private let listId = Expression<Int64>("listId")
    private let nameList = Expression<String?>("nameList")
    
    private var db: Connection?
    
    init?() {
        do {
            try setupDatabase()
        } catch {
            print(error)
            return nil
        }
    }
    
    // MARK: - Prtiavte create functions
    private func setupDatabase() throws {
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        do {
            db = try Connection("\(path)/db.sqlite3")
            try createToDosTable()
            try createListTable()
        } catch {
            throw error
        }
    }
    
    private func createToDosTable() throws {
        do {
            try db!.run(detailTable.create(ifNotExists: true) {
                t in
                
                t.column(id, primaryKey: .autoincrement)
                t.column(toDo, unique: true)
                t.column(state)
                t.column(listId)
            })
        } catch {
            throw error
        }
    }

    private func createListTable() throws {
        do {
            try db!.run(Table("listTable").create(ifNotExists: true) {
                t in
                
                t.column(id, primaryKey: .autoincrement)
                t.column(nameList)
            })
        } catch {
            throw error
        }
    }
    
    // MARK: - Create functions
    func createToDo(ToDo: String, listId: Int64) throws {
        
        let insert = detailTable.insert(self.toDo <- ToDo, self.state <- true, self.listId <- listId)
        
        do {
            let rowId = try db!.run(insert)
            print("Done with creating:", rowId)
        } catch {
            throw error
        }
    }
    
    func createList(name: String) throws {
        
        let insert = listTable.insert(self.nameList <- name)
        
        do {
            let rowId = try db!.run(insert)
            print("Done with creating:", rowId)
        } catch {
            throw error
        }
    }
    
    // MARK: - Detail functions
    func read(idList: Int64) throws -> Array<String> {
        
        var result = Array<String>()
        
        do {
            for item in try db!.prepare(detailTable) {
                if item[listId] == idList {
                    result.append(item[toDo]!)
                }
            }
        } catch {
            throw error
        }
        return result
    }
    
    func getStatus(toDoName: String) throws -> Bool {
        let result = detailTable.select(state).filter(toDo == toDoName)

        do {
            var checked = Bool()
            for user in try db!.prepare(result){
                checked = user[self.state]
            }
            return checked
        } catch {
            throw error
        }
    }
    
    func changeBool(item: String, value: Bool) throws {
        let changeRow = detailTable.filter(toDo == item)
        do {
            let updateChecked = try db!.run(changeRow.update(state <- value))
            print("Done with updating:", updateChecked)
        } catch {
            throw error
        }
    }
    
    // MARK: - List functions
    func getListId(listName: String) -> Int64 {
        var returnID = Int64()
        do {
            for item in try db!.prepare(listTable) {
                if item[nameList]! == listName {
                    returnID = item[id]
                    break
                }
            }
        } catch {
            print(error)
        }
        return returnID
    }
        
    func getLists() throws -> Array<String>? {
        var result = [String]()
        do {
            for item in try db!.prepare(listTable) {
                result.append(item[nameList]!)
            }
        } catch {
            throw error
        }
        return result
    }

        
    // MARK: - Delete functions
    func deleteToDo(id: Int64, toDoName: String) throws {
        let deleteRow = detailTable.filter(listId == id).filter(toDo == toDoName)
        
        do {
            let numDeleteRow = try db!.run(deleteRow.delete())
            print("Done with deleting:", numDeleteRow)
        } catch {
            throw error
        }
    }
        
    func deleteList(id: Int64, listName: String) throws {
        let deleteToDos = detailTable.filter(listId == id)
        do {
            let deleteNameToDos = try db!.run(deleteToDos.delete())
            print("Done with deleting:", deleteNameToDos)
        } catch {
            throw error
        }
        let deleteList = listTable.filter(nameList == listName)
        do {
            let deleteNameList = try db!.run(deleteList.delete())
            print("Done with deleting:", deleteNameList)
        } catch {
            throw error
        }
    }
}
