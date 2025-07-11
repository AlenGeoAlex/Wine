//
//  ImageEditorWindowController.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//

import AppKit
import SwiftUI

class ImageEditorWindowController: NSWindowController, NSWindowDelegate {

    var onClose: (() -> Void)?
    
    init(for capture: Capture) {
        let swiftUIView = ImageEditor(for: capture)
        let hostingView = NSHostingView(rootView: swiftUIView)

        let window = NSWindow(
            contentRect: .zero,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.isReleasedWhenClosed = false
        window.title = "Image Editor - \(capture.filePath.lastPathComponent)"
        window.contentView = hostingView
        window.center()
        window.minSize = NSSize(width: 640, height: 480)
        window.setContentSize(NSSize(width: 800, height: 600))
        
        super.init(window: window)

        window.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func windowWillClose(_ notification: Notification) {
        onClose?()
    }
}
