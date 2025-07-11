//
//  WindowService.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//

import AppKit
import SwiftUI
import Foundation

class WindowService {
    
    private var windowControllers: [UUID: NSWindowController] = [:]
    
    /// Opens the editor window for a given capture, or brings an existing one to the front.
    func openEditorWindow(for capture: Capture) {
        if let existingController = windowControllers[capture.id] {
            existingController.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let newController = ImageEditorWindowController(for: capture)
        newController.onClose = { [weak self] in
            self?.windowControllers.removeValue(forKey: capture.id)
        }
        
        windowControllers[capture.id] = newController
        
        newController.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
