//
//  KeyboardKey.swift
//  Wine
//
//  Created by Alen Alex on 21/06/25.
//


import SwiftUI
import AppKit

extension KeyboardKey {
    
    /// Converts this `KeyboardKey` into a SwiftUI `KeyboardShortcut`.
    /// Returns `nil` if the key character is not set, as `KeyboardShortcut` requires a base key.
    var swiftUIKeyboardShortcut: KeyboardShortcut? {
        guard let keyEquivalent = key else { return nil }
        
        var swiftUIModifiers = EventModifiers()
        if modifiers.contains(.command) { swiftUIModifiers.insert(.command) }
        if modifiers.contains(.shift) { swiftUIModifiers.insert(.shift) }
        if modifiers.contains(.option) { swiftUIModifiers.insert(.option) }
        if modifiers.contains(.control) { swiftUIModifiers.insert(.control) }
        
        return KeyboardShortcut(KeyEquivalent(keyEquivalent), modifiers: swiftUIModifiers)
    }
}


extension KeyboardKey {
    
    /// Checks if this `KeyboardKey` is equivalent to a given SwiftUI `KeyboardShortcut`.
    ///
    /// - Parameter shortcut: The `KeyboardShortcut` to compare against.
    /// - Returns: `true` if they represent the same key combination, `false` otherwise.
    func isEqualTo(_ shortcut: KeyboardShortcut) -> Bool {
        guard let selfKey = self.key, selfKey == shortcut.key.character else {
            return false
        }
        
        var shortcutModifiers = NSEvent.ModifierFlags()
        if shortcut.modifiers.contains(.command) { shortcutModifiers.insert(.command) }
        if shortcut.modifiers.contains(.shift) { shortcutModifiers.insert(.shift) }
        if shortcut.modifiers.contains(.option) { shortcutModifiers.insert(.option) }
        if shortcut.modifiers.contains(.control) { shortcutModifiers.insert(.control) }
        
        return self.modifiers == shortcutModifiers
    }
}

extension NSEvent.ModifierFlags {
    /// A user-friendly string of symbols representing the modifier keys (e.g., "⌃⌥⌘").
    var symbolicRepresentation: String {
        var symbols = ""
        if contains(.control) { symbols += "⌃" }
        if contains(.option) { symbols += "⌥" }
        if contains(.shift) { symbols += "⇧" }
        if contains(.command) { symbols += "⌘" }
        return symbols
    }
    
    func toEventModifiers() -> EventModifiers {
        var modifiers: EventModifiers = []
        if contains(.command) { modifiers.insert(.command) }
        if contains(.shift) { modifiers.insert(.shift) }
        if contains(.option) { modifiers.insert(.option) }
        if contains(.control) { modifiers.insert(.control) }
        return modifiers
    }
}
