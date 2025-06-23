//
//  ScreenCaptureImage.swift
//  Wine
//
//  Created by Alen Alex on 22/06/25.
//

import Foundation
import AppKit
import UniformTypeIdentifiers
import OSLog

class SCImageCapture : ImageCaptureProtocol {
    
    private let logger : Logger = Logger(subsystem: AppConstants.reversedDomain, category: "SCImageCapture")
    
    /// Capture image with Selection
    func captureImageWithSelection() async throws -> Result<URL, CaptureError> {
        let datePath : String = AppConstants.FolderStructureDateFormatter.string(from: Date());
        let tempFolder = FileManager.default.temporaryDirectory.appendingPathComponent(datePath)
        let tempFile = tempFolder.appendingPathComponent(UUID().uuidString, conformingTo: UTType.png)
        
        if(!FileManager.default.fileExists(atPath: tempFolder.path())){
            try FileManager.default.createDirectory(at: tempFolder, withIntermediateDirectories: true)
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        process.arguments = ["-i", "-s", "-x", tempFile.path]
        
        do {
            try process.run();
            process.waitUntilExit();
            
            guard process.terminationStatus == 0 else {
                logger.warning("User cancelled selection")
                return .failure(.userCancelledSelection);
            }
            
            guard FileManager.default.fileExists(atPath: tempFile.path) else {
                logger.error("No image has been found at path \(tempFile.path)")
                return .failure(.userCancelledSelection);
            }
            
        
            return .success(tempFile);
        }catch {
            logger.error("Failed to capture image: \(error)")
            return .failure(.streamError(error))
        }
    }
    
    /// Capture an entire screen
    func captureScreen(id: Int) async throws ->  Result<URL, CaptureError> {
        let datePath : String = AppConstants.FolderStructureDateFormatter.string(from: Date());
        let tempFolder = FileManager.default.temporaryDirectory.appendingPathComponent(datePath)
        let tempFile = tempFolder.appendingPathComponent(UUID().uuidString, conformingTo: UTType.png)
        
        if(!FileManager.default.fileExists(atPath: tempFolder.path())){
            try FileManager.default.createDirectory(at: tempFolder, withIntermediateDirectories: true)
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "screencapture")
        process.arguments = ["-D\(id)", "-s", "-x", tempFile.path]
        
        do {
            try process.run();
            process.waitUntilExit();
            
            guard process.terminationStatus == 0 else {
                logger.warning("User cancelled selection")
                return .failure(.userCancelledSelection);
            }
            
            guard FileManager.default.fileExists(atPath: tempFile.path) else {
                logger.error("No image has been found at path \(tempFile.path)")
                return .failure(.userCancelledSelection);
            }
            
            
            return .success(tempFile);
        }catch {
            logger.error("Failed to capture image: \(error)")
            return .failure(.streamError(error))
        }
    }
}
