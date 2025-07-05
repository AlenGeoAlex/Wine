//
//  OutputFileType.swift
//  Wine
//
//  Created by Alen Alex on 21/06/25.
//
enum OutputFileType : Identifiable, Codable, Equatable, Hashable, CaseIterable {
    case png
    case jpeg
    case mp4
    
    var fileExtension: String {
        switch self {
        case .png:
            return "png"
        case .jpeg:
            return "jpg"
        case .mp4:
            return "mp4"
        }
    }
    
    var id: String {
        switch self {
        case .jpeg:
            return "jpeg"
        case .png:
            return "png"
        case .mp4:
            return "mp4"
        }
    }
    
    var mimeType: String {
        switch self {
        case .jpeg:
            return "image/jpeg"
        case .png:
            return "image/png"
        case .mp4:
            return "video/mp4"
        }
    }
    
}
