/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation
import TodoListAPI
import LoggerAPI
import SwiftyJSON
import MySQL
import Dispatch

public class TodoList : TodoListAPI {
    
    static let defaultHost = "127.0.0.1"
    static let defaultPort = 3306
    static let defaultUser = "root"
    static let defaultPassword = ""
    static let defaultDatabase = "todolist"
    
    private let racePrevention = DispatchSemaphore( value: 0 )
    
    private func oneAtATime(_ fn: () -> Void) {
        defer { racePrevention.signal() }
        racePrevention.wait()
        fn()
    }
    
    private let queue = DispatchQueue(label: "database queue",
                                      attributes: .concurrent)
                                    
    
    let database: String, host: String, username: String, password: String
    
    public init(database: String = TodoList.defaultDatabase,
                host:     String = TodoList.defaultHost,
                username: String = TodoList.defaultUser,
                password: String = TodoList.defaultPassword) {
        
        self.database = database
        self.host = host
        self.username = username
        self.password = password
        
    }
    
    public init(_ dbConfiguration: DatabaseConfiguration) {
        
        
        self.database = TodoList.defaultDatabase
        self.host = dbConfiguration.host!
        self.username = dbConfiguration.username!
        self.password = dbConfiguration.password!
        
    }
    
    private func getDatabase() throws -> (MySQL.Database?, Connection?) {
        
        do{
            let mysql = try MySQL.Database(
                host:     self.host,
                user:     self.username,
                password: self.password,
                database: self.database
            )
            let connection = try mysql.makeConnection()
            return (mysql, connection)
        } catch {
            Log.error("Failed to create a connection to MySQL database")
        }
        return (nil, nil)
    }
    
    public func count(withUserID: String?, oncompletion: (Int?, ErrorProtocol?) -> Void) {
        let user = withUserID ?? "default"
        
        do {
            let query = "SELECT * FROM todos WHERE owner_id=\"\(user)\""
            let results = try getDatabase().0?.execute(query)
            oncompletion(results?.count, nil)
            
        }
        catch {
            Log.error("There was a problem with the MySQL query: \(error)")
            oncompletion(nil, TodoCollectionError.CreationError("There was a problem with the MySQL query: \(error)"))
        }
    }
    
    public func clear(withUserID: String?, oncompletion: (ErrorProtocol?) -> Void) {
        let user = withUserID ?? "default"
        
        do {
            let query = "DELETE FROM todos WHERE owner_id=\"\(user)\""
            
            oneAtATime {
                self.queue.async {
                    try! self.getDatabase().0?.execute(query)
                    oncompletion(nil)
                }
            }
            
        }
        catch {
            Log.error("There was a problem with the MySQL query: \(error)")
            oncompletion(TodoCollectionError.CreationError("There was a problem with the MySQL query: \(error)"))
        }
    }
    
    public func clearAll(oncompletion: (ErrorProtocol?) -> Void) {
        do {
            let query = "TRUNCATE TABLE todos"
            try getDatabase().0?.execute(query)
            oncompletion(nil)
            
        }
        catch {
            Log.error("There was a problem with the MySQL query: \(error)")
            oncompletion(TodoCollectionError.CreationError("There was a problem with the MySQL query: \(error)"))
        }
    }
    
    public func get(withUserID: String?, oncompletion: ([TodoItem]?, ErrorProtocol?) -> Void) {
        let user = withUserID ?? "default"
        
        do {
            let query = "SELECT * FROM todos WHERE owner_id=\"\(user)\""
            let results = try getDatabase().0?.execute(query)
            
            let todos = try parseTodoItemList(results: results!)
            oncompletion(todos, nil)
            
        }
        catch {
            Log.error("There was a problem with the MySQL query: \(error)")
            oncompletion(nil, TodoCollectionError.CreationError("There was a problem with the MySQL query: \(error)"))
        }
    }
    
    public func get(withUserID: String?, withDocumentID: String, oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
        let user = withUserID ?? "default"
        
            
        do {
            let query = "SELECT * FROM todos WHERE owner_id=\"\(user)\" AND tid=\"\(withDocumentID)\""
            
            
            let results = try self.getDatabase().0?.execute(query)
            
            
            guard let order = results?[0]["orderno"]?.int else {
                Log.error("There was a problem with the MySQL query")
                oncompletion(nil, TodoCollectionError.CreationError("Problem retrieving the TODO list item"))
                return
            }
            
            guard let title = results?[0]["title"]?.string else {
                Log.error("There was a problem with the MySQL query")
                oncompletion(nil, TodoCollectionError.CreationError("Problem retrieving the TODO list item"))
                return
            }
            
            guard let completed = results?[0]["completed"]?.int else {
                Log.error("There was a problem with the MySQL query")
                oncompletion(nil, TodoCollectionError.CreationError("Problem retrieving the TODO list item"))
                return
            }
            
            let completedValue = completed == 1 ? true : false
            
            oncompletion(TodoItem(documentID: withDocumentID, userID: user, order: order, title: title, completed: completedValue), nil)
        }
        catch {
            Log.error("There was a problem with the MySQL query: \(error)")
            oncompletion(nil, TodoCollectionError.CreationError("There was a problem with the MySQL query: \(error)"))
        }
        
    }
    
    public func add(userID: String?, title: String, order: Int, completed: Bool,
                    oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
  
   
                
        let user = userID ?? "default"
        
        do {
            let completedValue = completed ? 1 : 0
            
            let query = "INSERT INTO todos (title, owner_id, completed, orderno) VALUES ( \"\(title)\", \"\(user)\", \(completedValue), \(order))"
            
            let dbConnection = try self.getDatabase()
            
            
            try dbConnection.0?.execute(query, [], dbConnection.1)
            
            let result = try dbConnection.0?.execute("SELECT LAST_INSERT_ID()", [], dbConnection.1)
            
            guard result?.count == 1 else {
                oncompletion(nil, TodoCollectionError.IDNotFound("There was a problem adding a TODO item"))
                return
            }
            
            guard let documentID = (result?[0]["LAST_INSERT_ID()"])?.int
                where documentID > 0 else {
                    oncompletion(nil, TodoCollectionError.IDNotFound("There was a problem adding a TODO item"))
                    return
            }
            let todoItem = TodoItem(documentID: String(documentID), userID: user, order: order, title: title, completed: completed)
            
           
            oncompletion(todoItem, nil)
           
        }
            
        catch {
            Log.error("There was a problem with the MySQL query: \(error)")
            oncompletion(nil, TodoCollectionError.CreationError("There was a problem with the MySQL query: \(error)"))
        }
     
    }
    
    public func update(documentID: String, userID: String?, title: String?, order: Int?,
                       completed: Bool?, oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
        let user = userID ?? "default"
        
        var originalTitle: String = "", originalOrder: Int = 0, originalCompleted: Bool = false
        var titleQuery: String = "", orderQuery: String = "", completedQuery: String = ""
        
        get(withUserID: userID, withDocumentID: documentID){
            todo, error in
            
            if let todo = todo {
                originalTitle = todo.title
                originalOrder = todo.order
                originalCompleted = todo.completed
            }
            
            let finalTitle = title ?? originalTitle
            if (title != nil) {
                titleQuery = " title=\"\(finalTitle)\","
            }
            
            let finalOrder = order ?? originalOrder
            if (order != nil) {
                orderQuery = " orderno=\(finalOrder),"
            }
            
            let finalCompleted = completed ?? originalCompleted
            if (completed != nil) {
                let completedValue = finalCompleted ? 1 : 0
                completedQuery = " completed=\(completedValue),"
            }
            
            var concatQuery = titleQuery + orderQuery + completedQuery
            
            do {
                let query = "UPDATE todos SET" + String(concatQuery.characters.dropLast()) + " WHERE tid=\"\(documentID)\""
                
                let dbConnection = try self.getDatabase()
                
                self.queue.sync {
                try! dbConnection.0?.execute(query, [], dbConnection.1)
                
                let todoItem = TodoItem(documentID: String(documentID), userID: user, order: finalOrder, title: finalTitle, completed: finalCompleted)
                oncompletion(todoItem, nil)
                }
                
            }
            catch {
                Log.error("There was a problem with the MySQL query: \(error)")
                oncompletion(nil, TodoCollectionError.CreationError("There was a problem with the MySQL query: \(error)"))
            }
        }
    }
    
    public func delete(withUserID: String?, withDocumentID: String, oncompletion: (ErrorProtocol?) -> Void) {
        let user = withUserID ?? "default"
        
        do {
            let query = "DELETE FROM todos WHERE owner_id=\"\(user)\" AND tid=\"\(withDocumentID)\""
            
            try getDatabase().0?.execute(query)
            
            oncompletion(nil)
            
        }
        catch {
            Log.error("There was a problem with the MySQL query: \(error)")
            oncompletion(TodoCollectionError.IDNotFound("There was a problem with the MySQL query: \(error)"))
        }
    }
    
    
    private func parseTodoItemList(results: [[String : MySQL.Value]]) throws -> [TodoItem] {

        var todos = [TodoItem]()
        for entry in results {
            let item: TodoItem = try createTodoItem(entry: entry)
            todos.append(item)
            
        }
        return todos
    }
    
    private func createTodoItem(entry: [String : MySQL.Value]) throws -> TodoItem {
      
        var tid: Int = 0, user: String = "", title: String = "", orderno: Int = 0, completed: Int = 0
        for(key, value) in entry {
            
            if key == "tid" {
                tid = value.int!
                continue
            }
            if key == "owner_id" {
                user = value.string!
                continue
            }
            if key == "title" {
                title = value.string!
                continue
            }
            if key == "orderno" {
                orderno = value.int!
                continue
            }
            if key == "completed" {
                completed = value.int!
                continue
            }
        }
        let completedValue = completed == 1 ? true : false
        
        let todoItem = TodoItem(documentID: String(tid), userID: user, order: orderno, title: title, completed: completedValue)
        return todoItem
        
    }
}
