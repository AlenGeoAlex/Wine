//
//  NSScreen+Extensions.swift
//  Wine
//
//  Created by Alen Alex on 26/06/25.
//

import AppKit

extension NSScreen {
    /// Returns the screen that currently contains the mouse pointer.
    static var active: NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        let screens = NSScreen.screens
        let screenWithMouse = screens.first { $0.frame.contains(mouseLocation) }
        return screenWithMouse ?? NSScreen.main
    }
}
