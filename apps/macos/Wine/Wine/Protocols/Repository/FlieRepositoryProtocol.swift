//
//  FlieRepositoryProtocol.swift
//  Wine
//
//  Created by Alen Alex on 10/07/25.
//

import Foundation
protocol FileRegexRepositoryProtocol {
    
    /// Sends an api request to create the file
    func createFile(with content: FileCreateRequest) async -> Result<FileCreateResponse, Error>;
    
}
