//
//  FileCreateRequestResponse.swift
//  Wine
//
//  Created by Alen Alex on 10/07/25.
//

import Foundation

struct FileCreateRequest: Codable {
    let fileName, extensions: String?
    let expiration : Date?
    let secret: String?
    let tags: [String]
    let contentType: String
}

struct FileCreateResponse : Codable {
    
}

// MARK: FileCreateRequest convenience initializers and mutators

extension FileCreateRequest {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FileCreateRequest.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        fileName: String? = nil,
        extensions: String? = nil,
        expiration: Date? = nil,
        secret: String? = nil,
        tags: [String]? = nil,
        contentType: String? = nil
    ) -> FileCreateRequest {
        return FileCreateRequest(
            fileName: fileName ?? self.fileName,
            extensions: extensions ?? self.extensions,
            expiration: expiration ?? self.expiration,
            secret: secret ?? self.secret,
            tags: tags ?? self.tags,
            contentType: contentType ?? self.contentType
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
