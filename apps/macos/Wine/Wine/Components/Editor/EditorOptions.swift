//
//  EditorOptions.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//

import AppKit
import Foundation
import FactoryKit
import SwiftUI

@Observable class EditorOptions {
    var aspectRatio: AspectRatio = .square
    var backgroundType: BackgroundType = .gradient
    var backgroundColor: Color = .blue
    var backgroundGradient: Gradient = Gradient(colors: [.blue, .purple, .cyan])
    var horizontalPadding: CGFloat = 40.0
    var verticalPadding: CGFloat = 20.0

    var cornerRadius: CGFloat = 12
    var imageCornerRadius: CGFloat = 12
    var is3DEffect: Bool = false
    var perspective3DDirection: Perspective3DDirection = .bottomRight
    
    var annotations: [TextAnnotation] = []
    var elements: [any CanvasElement] = []
}
