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
    
    
    // Background
    var backgroundType: BackgroundType = .gradient
    var backgroundColor: Color = .blue
    var backgroundGradient: Gradient = Gradient(colors: [.blue, .purple, .cyan])
    var cornerRadius: CGFloat = 12
    var backgroundImageUrl: ImageSource?
    var backgroundImageBlurRadius: CGFloat = 0
    
    var imageCornerRadius: CGFloat = 12

    var elements: [any CanvasElement] = []
    
    func images() -> [ImageElement] {
        return elements.filter { $0 is ImageElement } as! [ImageElement]
    }
}
