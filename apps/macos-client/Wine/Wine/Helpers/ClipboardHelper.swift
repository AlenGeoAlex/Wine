//
//  ClipboardHelper.swift
//  Wine
//
//  Created by Alen Alex on 22/06/25.
//

import AppKit
import Foundation
import OSLog

class ClipboardHelper {
    
    private static let logger : Logger = Logger(subsystem: AppConstants.reversedDomain, category: "ClipboardHelper")
    
    @discardableResult
    static func copyImageToClipboard(image: NSImage) -> Bool {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        let success = pasteboard.writeObjects([image])
        if success {
            logger.info("Copied image to the logger")
        } else {
            logger.error("Failed to copy image to the logger")
        }
        
        return success
    }
    
    @discardableResult
    static func copyFileToClipboard(fileURL: URL) -> Bool {
        guard fileURL.isFileURL, FileManager.default.fileExists(atPath: fileURL.path) else {
            logger.error("Invalid file URL or file does not exist at path: \(fileURL.path)")
            return false
        }
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        let success = pasteboard.writeObjects([fileURL as NSURL])

        if success {
            logger.info("Successfully copied file at \(fileURL.path) to clipboard.")
        } else {
            logger.error("Failed to copy file to clipboard.")
        }
        
        return success
    }
}
