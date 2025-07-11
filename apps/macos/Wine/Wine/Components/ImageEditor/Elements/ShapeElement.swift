//
//  ShapeElement.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//
import AppKit
import Foundation
import SwiftUI

struct ShapeElement: CanvasElement, View {
    let id = UUID()
    var position: CGPoint
    var isSelected: Bool = false
    
    var shapeType: ShapeType
    var size: CGSize
    var color: Color
    
    var body: some View {
        switch shapeType {
        case .rectangle:
            Rectangle()
                .stroke(color, lineWidth: 5)
                .frame(width: size.width, height: size.height)
                .position(position)
        case .ellipse:
            Ellipse()
                .stroke(color, lineWidth: 5)
                .frame(width: size.width, height: size.height)
                .position(position)
        }
    }
}
