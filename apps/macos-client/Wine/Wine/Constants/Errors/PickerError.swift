//
//  PickerError.swift
//  Wine
//
//  Created by Alen Alex on 22/06/25.
//
enum PickerError : Error, Identifiable {
    case failed(Error)
    case cancelled
    
    var id : String {
        switch self {
        case .failed:
            return "failed"
        case .cancelled:
            return "cancelled"
        }
    }
    
    var description : String {
        switch self {
        case .cancelled:
            return "User has cancelled the stream selection";
        case .failed(let error):
            return "Failed to select stream: \(error)"
        }
    }
}
