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

import Kitura
import HeliumLogger
import LoggerAPI
import CloudFoundryEnv
import TodoList

Log.logger = HeliumLogger()
setbuf(stdout, nil)

let todos: TodoList

do {
    if let service = try CloudFoundryEnv.getAppEnv().getService(spec: "TodoList-MySQL"){
        
        let host: String, username: String, password: String, port: UInt16, database: String
        
        if let credentials = service.credentials{
            host = credentials["hostname"].stringValue
            username = credentials["username"].stringValue
            password = credentials["password"].stringValue
            port = UInt16(credentials["port"].stringValue)!
            database = credentials["name"].stringValue
            
        } else {
            host = "127.0.0.1"
            username = "root"
            password = ""
            port = UInt16(3306)
            database = "todolist"
            
        }
        let options = [String : AnyObject]()
        
        Log.verbose("Found TodoList-MySQL")
        todos = TodoList(database: database, host: host, username: username, password: password)
    } else {
        Log.info("Could not find Bluemix MySQL service")
        todos = TodoList()
    }
    
    let controller = TodoListController(backend: todos)
    
    let port = try CloudFoundryEnv.getAppEnv().port
    Log.verbose("Assigned port is \(port)")
    
    Kitura.addHTTPServer(onPort: port, with: controller.router)
    Kitura.run()
    
} catch CloudFoundryEnvError.InvalidValue {
    Log.error("Oops... something went wrong. Server did not start.")
}
