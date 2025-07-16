//
//  TextAnnotations.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//
import SwiftUI
import AppKit
import Foundation

@Observable
class TextAnnotation: CanvasElement {
    let id = UUID()
    var text: String
    var position: CGPoint
    var isSelected: Bool = false
    var isDirty: Bool = false

    var color: Color = .white
    var fontSize: CGFloat = 42.0
    var fontName: String = "Helvetica Neue"
    var isBold: Bool = false
    var isItalic: Bool = false
    var isUnderline: Bool = false
    var isStrikethrough: Bool = false
    
    var font: Font {
        var aFont = Font.custom(fontName, size: fontSize)
        
        if isBold {
            aFont = aFont.bold()
        }
        if isItalic {
            aFont = aFont.italic()
        }
        
        return aFont
    }
    
    // The view that renders the text will need to apply these separately
    // e.g., Text("...").underline(element.isUnderline)
    
    init(text: String = "Hello World", position: CGPoint) {
        self.text = text
        self.position = position
    }
}
