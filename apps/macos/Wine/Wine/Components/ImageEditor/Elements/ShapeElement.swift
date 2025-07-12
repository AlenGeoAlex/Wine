//
//  ShapeElement.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//
import AppKit
import Foundation
import SwiftUI

@Observable class ShapeElement: CanvasElement {
    let id = UUID()
    var position: CGPoint
    var isSelected: Bool = false
    
    var shapeType: ShapeType
    var size: CGSize
    var color: Color
    
    init(position: CGPoint, isSelected: Bool = false, shapeType: ShapeType, size: CGSize, color: Color) {
        self.position = position
        self.isSelected = isSelected
        self.shapeType = shapeType
        self.size = size
        self.color = color
    }
}
