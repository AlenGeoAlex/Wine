//
//  ImageHelper.swift
//  Wine
//
//  Created by Alen Alex on 12/07/25.
//
import SwiftUI
import Foundation
import AppKit
import OSLog

class ImageHelper {
    static func saveImage(_ image: NSImage, to url: URL) -> Bool {
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            Logger.common.error("Error: Could not get TIFF representation of the image.")
            return false
        }
        
        // Use PNG for good quality and transparency support.
        let pngData = bitmap.representation(using: .png, properties: [:])
        
        do {
            try pngData?.write(to: url)
            return true
        } catch {
            print("Error saving image to \(url): \(error)")
            return false
        }
    }
}
