//
//  FreehandLine.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//
import AppKit
import SwiftUI

@Observable
class FreehandLine: CanvasElement {
    let id = UUID()
    var position: CGPoint = .zero
    var isSelected: Bool = false
    var isDirty: Bool = false
    
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
 
    init(points: [CGPoint], color: Color, lineWidth: CGFloat) {
        self.points = points
        self.color = color
        self.lineWidth = lineWidth
    }
}
