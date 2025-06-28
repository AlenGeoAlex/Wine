//
//  FileHelpers.swift
//  Wine
//
//  Created by Alen Alex on 26/06/25.
//
import Foundation
import AppKit

class FileHelpers {
    
    public static func delete(file: URL) -> Result<Bool, Error> {
        do {
            try FileManager.default.removeItem(at: file)
            return .success(true)
        } catch {
            return .failure(error)
        }
    }
    
    public static func getFileSize(at url: URL) throws -> Int {
        let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
        
        guard let fileSize = resourceValues.fileSize else {
            throw NSError(domain: "FileSizeError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to get file size"])
        }
        
        return fileSize
    }
    
    public static func mimeTypeForPathExtension(_ ext: String) -> String {
        switch ext.lowercased() {
            // Images
            case "png": return "image/png"
            case "jpg", "jpeg": return "image/jpeg"
            case "gif": return "image/gif"
            case "webp": return "image/webp"
            case "heic": return "image/heic"
            case "bmp": return "image/bmp"
            case "tiff", "tif": return "image/tiff"
            case "svg": return "image/svg+xml"
            case "ico": return "image/x-icon"

            // Videos
            case "mp4": return "video/mp4"
            case "mov": return "video/quicktime"
            case "mkv": return "video/x-matroska"
            case "webm": return "video/webm"
            case "avi": return "video/x-msvideo"
            case "flv": return "video/x-flv"
            case "wmv": return "video/x-ms-wmv"

            // Audio
            case "mp3": return "audio/mpeg"
            case "wav": return "audio/wav"
            case "aac": return "audio/aac"
            case "ogg": return "audio/ogg"
            case "m4a": return "audio/mp4"
            case "flac": return "audio/flac"

            // Fallback
            default: return "application/octet-stream"
        }
    }
    
}
