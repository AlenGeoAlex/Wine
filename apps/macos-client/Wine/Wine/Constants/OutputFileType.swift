//
//  OutputFileType.swift
//  Wine
//
//  Created by Alen Alex on 21/06/25.
//
enum OutputFileType : Identifiable, Codable, Equatable, Hashable, CaseIterable {
    case png
    case jpeg
    
    var fileExtension: String {
        switch self {
        case .png:
            return "png"
        case .jpeg:
            return "jpg"
        }
    }
    
    var id: String {
        switch self {
        case .jpeg:
            return "jpeg"
        case .png:
            return "png"
        }
    }
    
    var mimeType: String {
        switch self {
        case .jpeg:
            return "image/jpeg"
        case .png:
            return "image/png"
        }
    }
    
}
