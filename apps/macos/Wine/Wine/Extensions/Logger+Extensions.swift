//
//  OSLog+Extensions.swift
//  Wine
//
//  Created by Alen Alex on 10/07/25.
//

import OSLog
extension Logger {
    /// The bundle identifier for the logs
    
    // MARK: Common Loggers
    static let common = Logger(subsystem: WineConstants.bundleIdentifier, category: "app")
    
    static func create(name: String = #file) -> Logger {
        return Logger(subsystem: WineConstants.bundleIdentifier, category: name)
    }
    
    // MARK: View Models
    
    
    // MARK: Repositories
    
    
    // MARK: Services
    
    
    // MARK: Models
}
