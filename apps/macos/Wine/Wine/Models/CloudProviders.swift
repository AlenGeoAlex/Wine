//
//  CloudProviders.swift
//  Wine
//
//  Created by Alen Alex on 10/07/25.
//

import Foundation
import Defaults
import OSLog

enum CloudProviders : Identifiable, CaseIterable {
    case wine(WineProviderOptions)
    case s3(S3ProviderOptions)
    case none
    
    var id : String {
        switch self {
        case .wine:
            return "wine"
        case .s3:
            return "s3"
        case .none:
            return "none"
        }
    }
    
    static var allCases: [CloudProviders] {
        [.wine(WineProviderOptions()), .s3(S3ProviderOptions()), .none]
    }
    
    var name : String {
        switch self {
        case .wine:
            return "Selfhosted Wine"
        case .s3:
            return "S3 Compatible API"
        case .none:
            return "None"
        }
    }
    
    
}

class WineProviderOptions {
    
}

class S3ProviderOptions {
    
}
