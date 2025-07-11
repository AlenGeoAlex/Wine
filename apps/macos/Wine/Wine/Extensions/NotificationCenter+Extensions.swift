//
//  NotificationCenter+Extensions.swift
//  Wine
//
//  Created by Alen Alex on 10/07/25.
//
import AppKit
import Foundation

extension Notification.Name {
    
    // Posts a message when the captured content is available for further processing or previews
    static let captureContentAvailable = Notification.Name("me.alenalex.wine.capture.content.available")
    
    // Posts a message when the preview panel is closed
    static let previewPanelClosed = Notification.Name("me.alenalex.wine.preview.panel.closed")
}
