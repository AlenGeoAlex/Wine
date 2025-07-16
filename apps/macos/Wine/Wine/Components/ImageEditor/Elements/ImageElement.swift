//
//  ImageElement.swift
//  Wine
//
//  Created by Alen Alex on 12/07/25.
//
import SwiftUI
import AppKit

@Observable
class ImageElement: CanvasElement {
    let id : UUID;
    var position: CGPoint
    var isSelected: Bool = false
    var isDirty: Bool = false

    let originalImage: NSImage
    var versions: [NSImage] = []
    var scale: CGFloat = 0.8
    var cornerRadius: CGFloat = 12.0
    var perspective3DDirection: Perspective3DDirection = .topLeft
    var is3DEffectEnabled: Bool = false
    
    var selectedImageIndex: Int?
    
    var imageToRender: NSImage {
        if let selectedIndex = selectedImageIndex {
            return versions[selectedIndex]
        }
        
        return versions.last ?? originalImage
    }
    
    init(id: UUID, image: NSImage, position: CGPoint = .zero) {
        self.id = id
        self.originalImage = image
        self.position = position
    }
    
    
    /**
     * Returns the 3D rotation angle based on selected direction
     */
    func get3DRotationAngle() -> Angle {
        switch self.perspective3DDirection {
        case .topLeft, .top, .topRight:
            return .degrees(15)
        case .bottomLeft, .bottom, .bottomRight:
            return .degrees(-15)
        }
    }
    
    /**
     * Returns the 3D rotation axis based on selected direction
     */
    func get3DRotationAxis() -> (x: CGFloat, y: CGFloat, z: CGFloat) {
        switch self.perspective3DDirection {
        case .topLeft:
            return (x: 1, y: 1, z: 0)
        case .top:
            return (x: 1, y: 0, z: 0)
        case .topRight:
            return (x: 1, y: -1, z: 0)
        case .bottomLeft:
            return (x: -1, y: 1, z: 0)
        case .bottom:
            return (x: -1, y: 0, z: 0)
        case .bottomRight:
            return (x: -1, y: -1, z: 0)
        }
    }
    
    /**
     * Returns the anchor point for rotation based on direction
     */
    func get3DRotationAnchor() -> UnitPoint {
        switch self.perspective3DDirection {
        case .topLeft:
            return .topLeading
        case .top:
            return .top
        case .topRight:
            return .topTrailing
        case .bottomLeft:
            return .bottomLeading
        case .bottom:
            return .bottom
        case .bottomRight:
            return .bottomTrailing
        }
    }
}
