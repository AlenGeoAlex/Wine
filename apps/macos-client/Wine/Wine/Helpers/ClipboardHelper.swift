//
//  ClipboardHelper.swift
//  Wine
//
//  Created by Alen Alex on 22/06/25.
//

import AppKit
import Foundation


class ClipboardHelper {
    public static func saveImageToTempFile(_ image: NSImage) throws -> URL {
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            throw CaptureError.invalidData
        }

        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".png")
        try pngData.write(to: fileURL)
        return fileURL
    }
}
