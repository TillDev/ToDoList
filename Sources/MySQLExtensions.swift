//
//  MySQLExtensions.swift
//  TodoList
//
//  Created by king on 7/13/16.
//
//

import Foundation
import MySQL

extension MySQL.Value {
    
    var string: String? {
        guard case .string(let string) = self else {
            return nil
        }
        
        return string
    }
    
    var int: Int? {
        guard case .int(let int) = self else {
            return nil
        }
        
        return int
    }
    
    var double: Double? {
        guard case .double(let double) = self else {
            return nil
        }
        
        return double
    }
    
    var uint: UInt? {
        guard case .uint(let uint) = self else {
            return nil
        }
        
        return uint
    }
}