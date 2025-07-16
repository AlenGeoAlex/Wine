//
//  EditorConstants.swift
//  Wine
//
//  Created by Alen Alex on 11/07/25.
//
import AppKit
import Foundation
import Cocoa
import SwiftUI

enum AspectRatio: String, CaseIterable, Identifiable {
    case square = "1:1"
    case widescreen = "16:9"
    case portrait = "9:16"
    case traditional = "4:3"
    case traditionalPortrait = "3:4"
    case photo = "3:2"
    case photoPortrait = "2:3"
    
    var id: String { self.rawValue }
    
    var ratio: CGFloat {
        switch self {
        case .square: return 1.0
        case .widescreen: return 16.0 / 9.0
        case .portrait: return 9.0 / 16.0
        case .traditional: return 4.0 / 3.0
        case .traditionalPortrait: return 3.0 / 4.0
        case .photo: return 3.0 / 2.0
        case .photoPortrait: return 2.0 / 3.0
        }
    }
    
    var displayName: String { rawValue }
}

enum BackgroundType: String, CaseIterable, Identifiable {
    case solid
    case gradient
    case image
    case none
    
    var id: String { self.rawValue }
    
    /**
     * Returns the display name for the background type
     */
    var displayName: String {
        switch self {
        case .solid: return "Solid Color"
        case .gradient: return "Gradient"
        case .image: return "Image"
        case .none: return "None"
        }
    }
}

enum Perspective3DDirection: String, CaseIterable, Identifiable {
    case topLeft
    case top
    case topRight
    case bottomLeft
    case bottom
    case bottomRight
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .topLeft: return "Top Left"
        case .top: return "Top"
        case .topRight: return "Top Right"
        case .bottomLeft: return "Bottom Left"
        case .bottom: return "Bottom"
        case .bottomRight: return "Bottom Right"
        }
    }
    
    var systemImageName: String {
        switch self {
        case .topLeft: return "arrow.up.left"
        case .top: return "arrow.up"
        case .topRight: return "arrow.up.right"
        case .bottomLeft: return "arrow.down.left"
        case .bottom: return "arrow.down"
        case .bottomRight: return "arrow.down.right"
        }
    }
}

enum ShapeType : Hashable, CaseIterable, Identifiable {
    case rectangle
    case ellipse
    
    var id: String {
        switch self {
        case .rectangle: return "rectangle"
        case .ellipse: return "ellipse"
        }
    }
    
}

enum DrawingTool: Equatable, Hashable {
    case select
    case text
    case shape(ShapeType)
    case freehand(color: Color, lineWidth: CGFloat)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .select:
            hasher.combine("select")
        case .text:
            hasher.combine("text")
        case .shape(let shapeType):
            hasher.combine("shape")
            hasher.combine(shapeType)
        case .freehand(let color, let lineWidth):
            hasher.combine("freehand")
            hasher.combine(color.description)
            hasher.combine(lineWidth)
        }
    }
    
    static func == (lhs: DrawingTool, rhs: DrawingTool) -> Bool {
        switch (lhs, rhs) {
        case (.select, .select):
            return true
        case (.text, .text):
            return true
        case (.shape(let lhsType), .shape(let rhsType)):
            return lhsType == rhsType
        case (.freehand, .freehand):
            return true
        default:
            return false
        }
    }
}

