//
//  ConsoleLogger.swift
//  QuantiLogger
//
//  Created by Martin Troup on 25.10.16.
//  Copyright © 2016 quanti. All rights reserved.
//

import Foundation

/// Pre-built logger that logs to the console.
public class ConsoleLogger: InternalBaseLogger, Loging {
    
    public func levels() -> [Level] {
        return levels
    }
    
    public func log(_ message: String, onLevel level: Level) {
        print("[\(level.rawValue) \(Date().toFullDateTimeString())] \(message)")
    }
    
}

