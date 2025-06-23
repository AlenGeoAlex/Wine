//
//  CaptureError.swift
//  Wine
//
//  Created by Alen Alex on 21/06/25.
//

import Foundation

enum CaptureError: Error, LocalizedError {
    case permissionDenied
    case displayNotFound
    case noContentAvailable
    case streamError(Error)
    case invalidData
    case userCancelledSelection
    case unknown

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Screen recording permission was not granted."
        case .displayNotFound:
            return "The specified display could not be found."
        case .noContentAvailable:
            return "No shareable content (displays, windows) is available."
        case .streamError(let underlyingError):
            return "The capture stream failed with an error: \(underlyingError.localizedDescription)"
        case .invalidData:
            return "The data received from the stream was invalid or could not be converted to an image."
        case .userCancelledSelection:
            return "The user cancelled the selection process."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
