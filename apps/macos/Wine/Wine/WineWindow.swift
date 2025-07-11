//
//  WineWindow.swift
//  Wine
//
//  Created by Alen Alex on 10/07/25.
//

import Cocoa
import AppKit

class WineWindow: NSWindow {

    init(
        contentRect: NSRect,
        styleMask: NSWindow.StyleMask,
        backing: NSWindow.BackingStoreType,
        defer flag: Bool,
        on screen: NSScreen?
    ) {
        super.init(contentRect: contentRect, styleMask: styleMask, backing: backing, defer: flag);
        self.level = .floating;
        self.isOpaque = false;
        self.backgroundColor = .clear;
        self.hasShadow = false;
        self.isMovable = true;
        self.collectionBehavior = [.canJoinAllApplications, .transient];
    }
    
    override var canBecomeKey: Bool {
        return true;
    }
    
}
