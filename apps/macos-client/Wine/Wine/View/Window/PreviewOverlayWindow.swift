//
//  OverlayWindow.swift
//  Wine
//
//  Created by Alen Alex on 25/06/25.
//

import Cocoa

class OverlayWindow: NSWindow {
    init(contentRect: NSRect, backing: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: .borderless, backing: backing, defer: flag)
        self.level = .floating
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = true
        self.isMovableByWindowBackground = true
        self.collectionBehavior = [.canJoinAllSpaces, .transient]
    }
    
    override var canBecomeKey: Bool {
        return true
    }
}
