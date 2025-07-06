//
//  FileList.swift
//  Wine
//
//  Created by Alen Alex on 06/07/25.
//

import Foundation
struct FileListQuery : Codable {
    let skip: Int?
    let take: Int?
}

struct FilesItem :  Codable, Identifiable {
    let id: String
    let expiration: Date?
    let fileName: String
    let size: Int?
    let tags: [String]?
    let contentType: String
    let createdAt: Date
    
    var relativeCreatedAt: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    var relativeExpiration: String {
        guard let expiration else { return "Never" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: expiration, relativeTo: Date())
    }
}

struct FileListResponse: Codable {
    let items: [FilesItem]
    let total: Int
}
