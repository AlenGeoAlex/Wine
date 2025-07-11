//
//  ScreenshotErrors.swift
//  Wine
//
//  Created by Alen Alex on 10/07/25.
//

import Foundation
enum ScreenshotError: Error, LocalizedError {
    case failed
    case unknown
    case cancelled
    
    var errorDescription: String? {
        switch self {
        case .cancelled:
            return "User has cancelled taking the screenshot."
        case .unknown:
            return "An unknown error happened while taking the screenshot."
        case .failed:
            return "Failed to take screenshot."
        }
    }
}
