//
//  DragPreviewHelper.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//
import AppKit
import Foundation
import OSLog
import Combine
import UniformTypeIdentifiers

class DragPreviewHelper {
    private let logger = Logger.create()
    
    static func createDragPreview(for capture: Capture, size: CGSize = CGSize(width: 100, height: 100)) -> NSImage? {
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        NSColor.black.withAlphaComponent(0.7).setFill()
        let backgroundRect = NSRect(origin: .zero, size: size)
        backgroundRect.fill()
        
        if capture.type.isScreenshot() {
            if let captureImage = NSImage(contentsOf: capture.filePath) {
                let imageRect = NSRect(x: 10, y: 10, width: size.width - 20, height: size.height - 20)
                captureImage.draw(in: imageRect, from: .zero, operation: .sourceOver, fraction: 1.0)
            }
        } else {
            // For videos, draw a play icon or video thumbnail
            let playIcon = NSImage(systemSymbolName: "play.fill", accessibilityDescription: "Play")
            playIcon?.draw(in: NSRect(x: size.width/2 - 15, y: size.height/2 - 15, width: 30, height: 30))
        }
        
        image.unlockFocus()
        return image
    }
}
