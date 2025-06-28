//
//  UploadServiceError.swift
//  Wine
//
//  Created by Alen Alex on 28/06/25.
//

import Foundation
enum UploadServiceError: Error {
    case failedToCreate
    case failedToUpload
    case unknownProvider
    case decodingError(Error)
    case serverUnreachable
    case unknown
    case unknownHttpError(Error)
}
