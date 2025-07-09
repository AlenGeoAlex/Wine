//
//  FileUpload.swift
//  Wine
//
//  Created by Alen Alex on 28/06/25.
//

import Foundation
struct FileUploadRequest : Codable, Hashable {
    let fileName : String
    let ext : String
    let size : Int
    let tags : [String]
    let contentType : String
    let expiration : String?
    
    enum CodingKeys : String, CodingKey {
        case fileName
        case ext = "extension"
        case size
        case tags
        case contentType
        case expiration
    }
}


struct FileUploadResponse : Codable, Hashable {
    let id : String
    let uploadType : UploadType
    
    
    enum UploadType : String, Hashable, Codable {
        case direct = "direct"
        case presigned = "presigned"
    }
}
