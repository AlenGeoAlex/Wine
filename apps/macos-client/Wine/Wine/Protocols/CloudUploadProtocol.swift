//
//  CloudUploadProtocol.swift
//  Wine
//
//  Created by Alen Alex on 25/06/25.
//

import Foundation
protocol CloudUploadProtocol {
    
    func startUpload(of fileURL: URL) async -> Result<Upload, Error>
    
    func pauseUpload(of: String)
    
    func resumeUpload(of: String)
    
    func get(of: String) -> Upload?
    
    func progressOf(of: String) -> Int?
    
}
