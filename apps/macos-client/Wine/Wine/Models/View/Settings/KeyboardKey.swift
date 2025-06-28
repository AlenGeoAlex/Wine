//
//  KeyboardKey.swift
//  Wine
//
//  Created by Alen Alex on 21/06/25.
//

import AppKit
import SwiftUI


/// A codable and hashable representation of a keyboard shortcut,
/// including a key and its modifier flags.
struct KeyboardKey: Equatable, Codable, Hashable {
    
    // The primary character of the shortcut (e.g., 'C', 'V', '1').
    // This is optional to allow for modifier-only shortcuts if needed, though less common.
    var key: Character?
    
    // The modifier flags (e.g., Command, Shift, Option).
    var modifiers: NSEvent.ModifierFlags
    
    static let empty : KeyboardKey = KeyboardKey(key: nil, modifiers: []);
    
    // MARK: - Computed Properties for Display
    
    /// A user-friendly string representation, e.g., "⌘⇧C".
    var displayText: String {
        guard let keyChar = self.key else {
            return "No Key Set"
        }
        
        let modText = modifiers.symbolicRepresentation
        
        switch keyChar {
        case "\u{F700}": return modText + "↑"   // upArrow
        case "\u{F701}": return modText + "↓"   // downArrow
        case "\u{F702}": return modText + "←"   // leftArrow
        case "\u{F703}": return modText + "→"   // rightArrow
        case " ":        return modText + "Space"
        case "\u{0008}": return modText + "⌫"   // delete (backspace)
        case "\u{001B}": return modText + "⎋"   // escape
        case "\r", "\n", "\u{F72C}": return modText + "⏎" // return/enter
        case "\t":       return modText + "⇥"   // tab
            
        // For all other standard characters, just uppercase them.
        default:
            return modText + String(keyChar).uppercased()
        }
    }
    
    init(key: Character?, modifiers: NSEvent.ModifierFlags) {
        self.key = key
        self.modifiers = modifiers
    }
    
    // MARK: - Codable Conformance
    
    private enum CodingKeys: String, CodingKey {
        case key
        case modifiers
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // 1. Decode the key as a String first.
        if let keyString = try container.decodeIfPresent(String.self, forKey: .key) {
            self.key = keyString.first
        } else {
            self.key = nil
        }
        
        let rawModifiers = try container.decode(UInt.self, forKey: .modifiers)
        self.modifiers = NSEvent.ModifierFlags(rawValue: rawModifiers)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let key = self.key {
            try container.encode(String(key), forKey: .key)
        }
        try container.encode(modifiers.rawValue, forKey: .modifiers)
    }
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
        hasher.combine(modifiers.rawValue)
    }
    
    static func == (lhs: KeyboardKey, rhs: KeyboardKey) -> Bool {
        return lhs.key == rhs.key &&
               lhs.modifiers.rawValue == rhs.modifiers.rawValue
    }
}
