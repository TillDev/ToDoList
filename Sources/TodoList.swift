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

public class TodoList : TodoListAPI {
    
    static let defaultHost = "127.0.0.1"
    //static let defaultPort: UInt16
    static let defaultUser = "root"
    static let defaultPassword = ""
    static let defaultDatabase = "todolist"
    
    var mysql: MySQL.Database?
    
    public init(database: String = TodoList.defaultDatabase,
                host: String = TodoList.defaultHost,
                username: String = TodoList.defaultUser,
                password: String = TodoList.defaultPassword) {
        
        do {
            mysql = try MySQL.Database(
                host: host,
                user: username,
                password: password,
                database: database
            )
        } catch {
            print("Error: \(error)")
        }
    }
    
    
    public init(_ dbConfiguration: DatabaseConfiguration) {
        
        do {
            mysql = try MySQL.Database(
                host: dbConfiguration.host!,
                user: dbConfiguration.username!,
                password: dbConfiguration.password!,
                database: TodoList.defaultDatabase
            )
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    
    
    public func count(withUserID: String?, oncompletion: (Int?, ErrorProtocol?) -> Void) {
        // TODO:
    }
    
    public func clear(withUserID: String?, oncompletion: (ErrorProtocol?) -> Void) {
        // TODO:
    }
    
    public func clearAll(oncompletion: (ErrorProtocol?) -> Void) {
        // TODO:
    }
    
    public func get(withUserID: String?, oncompletion: ([TodoItem]?, ErrorProtocol?) -> Void) {
        // TODO:
    }
    
    public func get(withUserID: String?, withDocumentID: String, oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
        
        let user = withUserID ?? "default"
        
        do {
            
            let query = "SELECT * FROM todos WHERE owner_id=\(user) AND tid=\(withDocumentID)"
            
            let results = try mysql?.execute(query)
            print("results: \(results)")
            
        }
        catch {
            print("Testing get item failed: \(error)")
        }
    }
    
    public func add(userID: String?, title: String, order: Int, completed: Bool,
                    oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
        
        let user = userID ?? "default"
        
        do {
            
            if let localMysql = mysql{
                
                let query = "INSERT INTO todos (title, owner_id, completed, orderno) VALUES ( \"\(title)\", \"\(user)\", \(completed), \(order))"
                try localMysql.execute(query)
                
                // LAST_INSERT_ID() returns a type MySQL.Value.int
                //let result = try localMysql.execute("SELECT LAST_INSERT_ID()")
                //let docID = (result[0]["LAST_INSERT_ID()"])
                
                //print("docID: \(docID)")
                //let todoItem = TodoItem(documentID: "", userID: user, order: order, title: title, completed: completed)
                
                //oncompletion(todoItem, nil)
                
            }
            
        }
        catch {
            print("Testing add item failed: \(error)")
        }
        
        
    }
    
    
    
    public func update(documentID: String, userID: String?, title: String?, order: Int?,
                       completed: Bool?, oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
        // TODO:
    }
    
    public func delete(withUserID: String?, withDocumentID: String, oncompletion: (ErrorProtocol?) -> Void) {
        // TODO:
    }
    
}



