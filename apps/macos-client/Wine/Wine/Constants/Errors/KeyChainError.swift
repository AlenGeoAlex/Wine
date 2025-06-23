//
//  KeyChainError.swift
//  Wine
//
//  Created by Alen Alex on 21/06/25.
//

import Foundation

enum KeyChainError : Error, Identifiable, Equatable {
    case unExpectedError(OSStatus)
    case noData
    case decodingFailed
    
    var id : String {
        switch self {
        case .unExpectedError(_):
            return "UnexpectedError"
        case .noData:
            return "noData"
        case .decodingFailed:
            return "decodingFailed"
        }
    }
    
    var message : String {
        switch self {
        case .unExpectedError(let stat):
            return "Failed due to unexpected error: \(stat)"
        case .noData:
            return "No data has been found in the key chain"
        case .decodingFailed:
            return "Failed to decode the keychain data"
        }
    }
}
